{*<!--修改编码格式:统一编码：UTF-8-->*}
{*@edit:liushuai @date:2020-08-14 @reason:0042287: 客户问题（立迈胜）合同订单模块>单据详情界面：点击“客户名称”超链接字段进入客户详情界面，“基本信息”区块点击“展开”按钮没有反应*}
<script type="text/javascript">
  AjaxJSPage("DetailViewPage_js",'include/js/SystemPopup/DetailViewPage.js');
</script>
<table border=0 cellspacing=0 cellpadding=0 width=100% >
  {foreach key=header item=detail from=$BLOCKS}
    {if $header eq 'show_origin_information'}
      <tr>
        <td class="" colspan="4" style="padding:0px;width:100%;">
          <div class="">{$RELATEDORDERINFORMATION}</div>
        </td>
      </tr>
    {else}
      <tr>
        <td style="width:100%;">
          <!-- Detailed View Code starts here-->
          <table border=0 cellspacing=0 cellpadding=0 width=100% >
            {assign var=publiclog value='RECORDSOFOPERATION'|@getFixedLabel}
            {if $header eq $publiclog  && $ACCOUNTSET eq 0}
              <tr id='publicaccountlogtr' style='display:none;'>
                <td>
                  {if $BLOCKINITIALSTATUS[$header] eq 0}
                    {assign var='arrawcls' value=''}
                  {else}
                    {assign var='arrawcls' value='On'}
                  {/if}
                  <div class="DivCName DivCNamehover" onclick="showHideStatus('publicaccountlog','aidpublicaccountlog');">
                    <span class="{$arrawcls}" id="aidpublicaccountlog"></span>{$header}
                  </div>
                  <div id="publicaccountlog" style="overflow: auto; height: 100px; width: 100%;display:block;padding-left: 5px;">
                    <!-- {$PUBLICACCOUNT_LOG} -->
                  </div>
                </td>
              </tr>
            {/if}
          </table>
          {if $header neq 'Comments'&& $header neq $publiclog}
            {if $BLOCKINITIALSTATUS[$header] eq 1|| $BLOCKINITIALSTATUS[$header] eq 3 || $BLOCKSTYLE == 1}
              {assign var='arrawcls' value=''}
            {else}
              {assign var='arrawcls' value='On'}
            {/if}
            {if $HIDDENSTYLE eq 1}
              <div class="DivCName">
                <!-- wym 20230406 详情页区块收起按钮优化 -->
                {if !empty($BLOCKS_LABELTOID[$header])}
                  <span class="{$arrawcls}" id="aid{$BLOCKS_LABELTOID[$header]|@str_replace:' ':''}" name="aid{$BLOCKS_LABELTOID[$header]|@str_replace:' ':''}"></span>{$header}
                {else}
                  <span class="{$arrawcls}" id="aid{$header|@str_replace:' ':''}" name="aid{$header|@str_replace:' ':''}"></span>{$header}
                {/if}
              </div>
            {else}
              {if !empty($BLOCKS_LABELTOID[$header])}
                {if $arrawcls=='On'}
                  <div class="DivCName DivCNamehover ld-shadow-first tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$BLOCKS_LABELTOID[$header]|@replace:' ':''}','aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}');">
                {else}
                  <div class="DivCName DivCNamehover tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$BLOCKS_LABELTOID[$header]|@replace:' ':''}','aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}');">
                {/if}
                  <span class="{$arrawcls}" id="aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}" name="aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}"></span>{$header}
              {else}
                  <div class="DivCName DivCNamehover tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$header|@replace:' ':''}','aid{$header|@replace:' ':''}');">
                  <span class="{$arrawcls}" id="aid{$header|@replace:' ':''}" name="aid{$header|@replace:' ':''}"></span>{$header}
              {/if}
                    {$header|@getBlockInfoForLinks:'detailview'}
                  </div>
            {/if}
          {/if}
          {if $header neq 'Comments'&& $header neq $publiclog}
            {if $BLOCKINITIALSTATUS[$header] eq 1 || $BLOCKINITIALSTATUS[$header] eq 3 || $BLOCKSTYLE == 1}
              <!-- wym 20230406 详情页区块收起按钮优化 -->
              {if !empty($BLOCKS_LABELTOID[$header])}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:block;" id="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" name="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" >
              {else}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:block;" id="tbl{$header|replace:' ':''}" name="tbl{$header|replace:' ':''}" >
              {/if}
            {else}
              {if !empty($BLOCKS_LABELTOID[$header])}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:none;" id="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" name="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" >
              {else}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:none;" id="tbl{$header|replace:' ':''}" name="tbl{$header|replace:' ':''}" >
              {/if}
            {/if}
                  <table border=0 cellspacing="1" cellpadding=0 width="100%" class="DetailContentTable ld-detail-tablecontent" style="table-layout: fixed;word-break: break-all; word-wrap: break-word;">
                    <tr><td style="width: 200px;height: 0;"></td><td style="width: calc(100% - 200px);height: 0;"></td><td style="width: 200px;height: 0;"></td><td style="width: calc(100% - 200px);height: 0;"></td></tr>
                    {foreach item=details from=$detail name=detailforeach}
                      <tr>
                        {foreach key=label item=data from=$details}
                          {assign var=keyid value=$data.ui}
                          {assign var=keyval value=$data.value}
                          {assign var=rawvalue value=$data.rawvalue}
                          {assign var=keytblname value=$data.tablename}
                          {assign var=keyfldname value=$data.fldname}
                          {assign var=pick_color value=$data.pick_color}
                          {assign var=keycolname value=$data.colname}
                          {assign var=keyfldid value=$data.fldid}
                          {assign var=keyoptions value=$data.options}
                          {assign var=keysecid value=$data.secid}
                          {assign var=keyseclink value=$data.link}
                          {assign var=keycursymb value=$data.cursymb}
                          {assign var=keysalut value=$data.salut}
                          {assign var=keyaccess value=$data.notaccess}
                          {assign var=keycntimage value=$data.cntimage}
                          {assign var=keyadmin value=$data.isadmin}
                          {assign var=display_type value=$data.displaytype}
                          {assign var=_readonly value=$data.readonly}
                          {assign var=fieldonly value=$data.fieldonly}
                          {assign var=allowedit value=$data.allowedit}
                          {assign var=allowprofilefieldedit value=$data.profileeditfield}
                          {assign var=value_name value=$data.value_name}
                          {*wsh 标签颜色*}
                          {assign var=label_style value=$data.label_style}
                          {*zxm 20211230字段颜色 字段说明样式*}
                          {assign var=fieldvaluecolor value=$data.fieldvaluecolor}
                          {assign var=fieldplaceholder value=$data.fieldplaceholder}
                          {*edit: xll 2023/06/08 XUQIU1001203 字段增加显示超链接属性*}
                          {assign var=ShowHyperlinks value=$data.ShowHyperlinks}
                          {assign var = BUSINESSQUERY value = $data.businessquery}{* 是否为工商查询字段 *}
                          {assign var = ENABLEBUSINESS value = $data.isenablebusiness}{* 是否启用工商查询 *}
                          {assign var = BUSINESSFUZZYQUERY value = $data.isenablebusinessfuzzyquery}{* 是否启用工商模糊查询 *}
                          {assign var = helptips value=$data.helptips}
                          {assign var = json_value value=$data.json_value}
                          {if $ACCOUNTSCONTACTS eq 'yes'}
                            {assign var=ID value=$data.recordid}
                            {assign var=MODULE value=$data.module}
                          {/if}
                          {if $label neq ''}
                            {*editor:gyq_170 reason:0039489: （51mis.com/kfbtest）客户模块明细界面：红框中全部要加上全角的冒号  2020/3/10 15:45*}
                            {assign var=oldlabel value=$label}
                            {* 2024-06-05 xxy 详情页去掉冒号 XUQIU20240603-02 页面设置/单据分录定制，字段类型增加“帮助信息”字段属性（朱俊） *}
                            {* {assign var=label value=$label|cat:"："} *}
                            {if $keyid neq '83' && $keyid neq '301'}
                              <td class="ld-form-item-label" style="{$label_style}">
                            {/if}
                            
                            {if $keycntimage ne ''}
                              {* <td class="ld-form-item-label"> *}
                              <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$keycntimage}</span>
                              {* </td> *}
                            {elseif $keyid eq '71' || $keyid eq '72'}<!-- Currency symbol -->
                              {* <td class="ld-form-item-label"> *}
                              <span>{$label}</span><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                              {* </td> *}
                            {elseif $keyid eq '9'}
                              {*BUG0053783 % 全部放开（潘）*}
                              {* <td class="ld-form-item-label"> *}
                              <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$oldlabel}(%)：</span>
                              {* </td> *}
                            {elseif $keyid eq '14'}
                              {* <td class="ld-form-item-label"> *}
                              <span>{$label}</span><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                              {* </td> *}
                            {elseif $keyid eq '202'}
                              {* <td class="ld-form-item-label"> *}
                              <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}{if $ISSOURCEMODULE} {$ISSOURCEMODULE|@getTranstab}{/if}</span>
                              {* </td> *}
                            {elseif $keyid eq '102'||$keyid eq '112'}
                              {* <td class="ld-form-item-label"> *}
                              <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}{if $ISSOURCEMODULE} {$ISSOURCEMODULE|@getTranstab}{/if}</span>
                              {* </td> *}
                            {elseif $keyid eq '15'}
                              {* <td class="ld-form-item-label"> *}
                              <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '1109' || $keyid eq '1108'}
                              {* <td class="ld-form-item-label"> *}
                                {*---wym---230217---BUG0061807：去掉详情页附件前的问号
                                <a id="AttachmentBlock" class="icon-homeimg icon-askgrey" style="cursor:pointer;margin:-4px 2px 0 0;" title="" onclick="getLinksUrl('0','module','AttachmentBlock');"></a>
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                *}
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'viewothers'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <span><b title="{'viewothers'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help "></b>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'editothers'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <span><b title="{'editothers'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'delothers'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <span><b title="{'delothers'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'viewselfbills'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span><b title="{'viewselfbills'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'edit_other_mobile'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}

                            {elseif $keyid eq '56' && $keyfldname eq 'setmenuprofileid'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'edit_me_mobile'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'is_mobile_style'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'select_servicedetail'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span></b>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'select_due_date'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'helpdesk_log'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '56' && $keyfldname eq 'accountallview'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {elseif $keyid eq '301'}
                              <td class="ld-form-item-content" colspan="4">
                                {assign var = tag_keyval value = htmlentities($keyval)}
                                <input type="hidden" name="detail_tagger_search" value="{$tag_keyval}" tag_id="" tag_type="{$keysecid}" id="detail_tagger_search" />
                                <script type="text/javascript">
                                  {literal}
                                    ld(document).ready(function(){
                                      ListTagDetailShow('detail_tagger_search');
                                    });
                                  {/literal}
                                </script>
                                <input name="add_moduledata_tag" module="{$MODULE}" onclick="detailbutton_click(this,'{$MODULE}','add_moduledata_tag','{$ID}');return false;" class="createautonew" value="{'Tagging'|@getFixedLabel}" type="button">
                              </td>
                            {elseif $keyid eq '56' && $keyfldname eq 'view_quantity'}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                <span>
                                  {if 'Quotes'|@vtlib_isModuleActive eq 'true' && 'SalesOrder'|@vtlib_isModuleActive eq 'true'}
                                    <b title="{'Quotes'|@getTranstab}{'AND'|@getTranstab}{'SalesOrder'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                                  {elseif 'Quotes'|@vtlib_isModuleActive eq 'true' && 'SalesOrder'|@vtlib_isModuleActive eq 'false'}
                                    <b title="{'Quotes'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                                  {elseif 'Quotes'|@vtlib_isModuleActive eq 'false' && 'SalesOrder'|@vtlib_isModuleActive eq 'true'}
                                    <b title="{'SalesOrder'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                                  {else}
                                    <b title="{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                                  {/if}
                                  {$label}
                                </span>
                              {* </td> *}
                            {elseif $keyid eq '83'}
                            {else}
                              {* wyt 221125 BUG0059116 去除产品管理详情页的帮助，将其以问号形式放在“总库存数量”字段前面（邱：可咨询周晓梅）*}
                              {* <td class="ld-form-item-label"> *}
                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                <span>{$label}</span>
                              {* </td> *}
                            {/if}
                            {if $keyid neq '83'}
                              {include file="Helptips.tpl"}
                              </td>
                            {/if}
                            {if $keyid neq 301}
                              {if $allowedit eq 'no'||$allowprofilefieldedit eq 'no' || $alloweditpage eq 'no'}
                                {include file="DetailNoEdit.tpl"}
                              {else}
                                {if (($USERPHOTOPERMIT eq 'yes'&&$keyid eq 105 )||$DETAILBUTTON.Edit.permit eq 'yes' ||$DETAILBUTTON.moduledetailEdit.permit eq 'yes' ) && $display_type neq '2' }
                                    {if !empty($DETAILVIEW_AJAX_EDIT)}
                                        {if $alloweditpage eq 'no' || $EDITSTATUS eq 'no' || $keyfldname eq 'currency_id'
                                            ||$keyfldname eq 'initmoney' || $_readonly == 1
                                             ||($MODULE eq 'BankAccountSet' && ($keyfldname eq 'initmoney' || $keyfldname eq 'currency_id')&& $CONFIRMEDST eq '1')
                                             ||(($MODULE eq 'Accounts'||$MODULE eq 'ServiceCharge')&& ($keytblname eq 'ld_contactdetails' || $keytblname eq 'LD_contactaddress' || $keytblname eq 'ld_contactscf')
                                              || ($MODULE eq 'Potentials' && $keyfldname eq 'sales_stage') )
                                              ||($MODULE eq 'Users'&&$keyfldname eq 'approvestatus')}

                                          {include file="DetailNoEdit.tpl"}
                                        {else}
                                          {include file="DetailViewUI.tpl"}
                                        {/if}
                                    {else}
                                      {include file="DetailViewFields.tpl"}
                                    {/if}
                                {else}
                                  {include file="DetailViewFields.tpl"}
                                {/if}
                              {/if}
                            {/if}
                          {else}
                          {/if}
                        {/foreach}
                      </tr>
                    {/foreach}
                  </table>
                </div>
          {/if}
        </td>
      </tr>
    {/if}
  {/foreach}
  <!-- 赛克特殊处理： -->
	{if $MODULE eq 'Accounts' && $VERSION_ACCOUNT eq 'saic'}
		<tr>
			<td colspan=4 class="editrelhead" style="padding:0">
				{include file='saic/saic_log.tpl'}
			</td>
		</tr>
	{/if}
</table>
<script type="text/javascript">
  var isadmin='{$keyadmin}';
</script>