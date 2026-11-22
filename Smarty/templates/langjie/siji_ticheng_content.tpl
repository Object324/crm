<input type="hidden" name="hidden_billid" id="hidden_billid" value="{$ID}"/>
<div style="text-align:center;font-size:23px;padding: 5px 0;">
	<input id="BasicSearchreput" class="createauto lfloat" name="submit" onclick="submitResult(event,'duizhang')" value="确认" type="button">
	司机提成表
</div>

<!---- 报关---->
{if $YEWULEIXING eq ''}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1860px;">
	<tr>                       
		<th style="width:80px"><span title="日期">日期</span></th>
		<th style="width:80px"><span title="车牌">车牌</span></th>
		<th style="width:80px"><span title="司机">司机</span></th>
		<th style="width:80px"><span title="状态">状态</span></th>
		<th style="width:120px"><span title="派车计划编号">派车计划编号</span></th>
		<th style="width:80px"><span title="小计">小计</span></th>
		<th style="width:120px"><span title="提货点1">提货点1</span></th>
		<th style="width:80px"><span title="派送客户1">派送客户1</span></th>
		<th style="width:80px"><span title="数量">数量</span></th>
		<th style="width:80px"><span title="形态1">形态1</span></th>
		<th style="width:120px"><span title="送货点1">送货点1</span></th>
		<th style="width:80px"><span title="提成费">提成费</span></th>
		<th style="width:80px"><span title="补贴费">补贴费</span></th>
		<th style="width:120px"><span title="提货点2">提货点2</span></th>
		<th style="width:80px"><span title="派送客户2">派送客户2</span></th>
		<th style="width:80px"><span title="数量">数量</span></th>
		<th style="width:80px"><span title="形态2">形态2</span></th>
		<th style="width:120px"><span title="送货点2">送货点2</span></th>
		<th style="width:80px"><span title="提成费">提成费</span></th>
		<th style="width:80px"><span title="补贴费">补贴费</span></th>
		<th style="width:120px"><span title="提货点3">提货点3</span></th>
		<th style="width:80px"><span title="派送客户3">派送客户3</span></th>
		<th style="width:80px"><span title="数量">数量</span></th>
		<th style="width:80px"><span title="形态3">形态3</span></th>
		<th style="width:120px"><span title="送货点3">送货点3</span></th>
		<th style="width:80px"><span title="提成费">提成费</span></th>
		<th style="width:80px"><span title="补贴费">补贴费</span></th>
		<th style="width:120px"><span title="提货点4">提货点4</span></th>
		<th style="width:80px"><span title="派送客户4">派送客户4</span></th>
		<th style="width:80px"><span title="数量">数量</span></th>
		<th style="width:80px"><span title="形态4">形态4</span></th>
		<th style="width:120px"><span title="送货点4">送货点4</span></th>
		<th style="width:80px"><span title="提成费">提成费</span></th>
		<th style="width:80px"><span title="补贴费">补贴费</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td title="{$row.date}">{$row.date}</td>
				<td title="{$row.chepai}">{$row.chepai}</td>
				<td title="{$row.siji}">{$row.siji}</td>
				<td title="{$row.is_duizhang}">{$row.is_duizhang}</td>
				<td title="{$row.jihua_no}">{$row.jihua_no}</td>
				<td title="{$row.xiaoji}">{$row.xiaoji}</td>
				<td title="{$row.tihuodian_01}">{$row.tihuodian_01}</td>
				<td title="{$row.kehu_01}">{$row.kehu_01}</td>
				<td title="{$row.qty_01}">{$row.qty_01}</td>
				<td title="{$row.xingtai_01}">{$row.xingtai_01}</td>
				<td title="{$row.songhuodian_01}">{$row.songhuodian_01}</td>
				<td title="{$row.tcfee_01}">{$row.tcfee_01}</td>
				<td title="{$row.btfee_01}">{$row.btfee_01}</td>
				<td title="{$row.tihuodian_02}">{$row.tihuodian_02}</td>
				<td title="{$row.kehu_02}">{$row.kehu_02}</td>
				<td title="{$row.qty_02}">{$row.qty_02}</td>
				<td title="{$row.xingtai_02}">{$row.xingtai_02}</td>
				<td title="{$row.songhuodian_02}">{$row.songhuodian_02}</td>
				<td title="{$row.tcfee_02}">{$row.tcfee_02}</td>
				<td title="{$row.btfee_02}">{$row.btfee_02}</td>
				<td title="{$row.tihuodian_03}">{$row.tihuodian_03}</td>
				<td title="{$row.kehu_03}">{$row.kehu_03}</td>
				<td title="{$row.qty_03}">{$row.qty_03}</td>
				<td title="{$row.xingtai_03}">{$row.xingtai_03}</td>
				<td title="{$row.songhuodian_03}">{$row.songhuodian_03}</td>
				<td title="{$row.tcfee_03}">{$row.tcfee_03}</td>
				<td title="{$row.btfee_03}">{$row.btfee_03}</td>
				<td title="{$row.tihuodian_04}">{$row.tihuodian_04}</td>
				<td title="{$row.kehu_04}">{$row.kehu_04}</td>
				<td title="{$row.qty_04}">{$row.qty_04}</td>
				<td title="{$row.xingtai_04}">{$row.xingtai_04}</td>
				<td title="{$row.songhuodian_04}">{$row.songhuodian_04}</td>
				<td title="{$row.tcfee_04}">{$row.tcfee_04}</td>
				<td title="{$row.btfee_04}">{$row.btfee_04}</td>
			</tr>
			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach item=value from=$DATA['subtotal'][$row.siji]}
					<tr class="lvtColData">
						<td colspan="5" align="right">小计：</td>
						<td colspan="29" align="left">{$value}</td>
					</tr>
					
				{/foreach}
			{/if}
		{/foreach}
		<tr class="lvtColData">
			<td colspan="5" align="right">合计：</td>
			<td colspan="29" align="left">{$DATA['total']}</td>
		</tr>
	{else}
		<tr class="lvtColData">
			<td colspan="34">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}
{if $YEWULEIXING eq '报关'}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1900px;">
	<tr>                       
		<th style="width:100px"><span title="费用单号">费用单号</span></th>
		<th style="width:80px"><span title="对接金蝶">对接金蝶</span></th>
		<th style="width:80px"><span title="对账状态">对账状态</span></th>
		<th style="width:80px"><span title="对接状态">对接状态</span></th>
		<th style="width:80px"><span title="业务分类">业务分类</span></th>
		<th style="width:200px"><span title="客户/供应商">客户/供应商</span></th>
		<th style="width:80px"><span title="JOB NO日期">JOB NO日期</span></th>
		<th style="width:100px"><span title="JOB NO">JOB NO</span></th>
		<th style="width:100px"><span title="JOB NO创建人">JOB NO创建人</span></th>
		<th style="width:150px"><span title="发票号">发票号</span></th>
		<th style="width:150px"><span title="出口日期">出口日期</span></th>
		<th style="width:150px"><span title="进口日期">进口日期</span></th>
		<th style="width:150px"><span title="申报口岸">申报口岸</span></th>
		<th style="width:150px"><span title="品名">品名</span></th>
		<th style="width:150px"><span title="数量">数量</span></th>
		<th style="width:150px"><span title="货值">货值</span></th>
		<th style="width:150px"><span title="件数">件数</span></th>
		<th style="width:150px"><span title="毛重">毛重</span></th>
		<th style="width:150px"><span title="报关单号">报关单号</span></th>
		<th style="width:150px"><span title="六连单号">六连单号</span></th>
		<th style="width:150px"><span title="费用项目">费用项目</span></th>
		<th style="width:150px"><span title="税率">税率</span></th>
		<th style="width:150px"><span title="未税金额">未税金额</span></th>
		<th style="width:150px"><span title="含税金额">含税金额</span></th>
		<th style="width:150px"><span title="币种">币种</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td>{$row.billno}</td>
				<td>{$row.istoerp}</td>
				<td><span id="{$row.billid}_zhuangtai">{$row.zhuangtai}</span></td>
				<td><span id="{$row.billid}_kis_id">{if $row.kis_id gt 0}已对接{else}未对接{/if}</span></td>
				<td>{$row.yewufenlei}</td>
				<td>{$row.accountorvendor}</td>
				<td>{$row.jobno_date}</td>
				<td>{$row.jobno}</td>
				<td>{$row.jobno_creator}</td>
				<td>{$row.fapiaohao}</td>
				<td>{$row.chukou_date}</td>
				<td>{$row.jinkou_date}</td>
				<td>{$row.shenbaokouan}</td>
				<td>{$row.pinming}</td>
				<td>{$row.qty}</td>
				<td>{$row.huozhi}</td>
				<td>{$row.jianshu}</td>
				<td>{$row.maozhong}</td>
				<td>{$row.baoguandanhao}</td>
				<td>{$row.trans_name}</td>
				<td>{$row.feiyongtype}</td>
				<td>{$row.shui}</td>
				<td>{$row.currency_symbol}{$row.weishui_amount}</td>
				<td>{$row.currency_symbol}{$row.hanshui_amount}</td>
				<td>{$row.currency_name}</td>
			</tr>
			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach key=$currency_name item=row from=$DATA['subtotal'][$row.accountorvendor]}
					<tr class="lvtColData">
						<td colspan="22" align="left">小计：{$currency_name}-税0%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax0']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax0']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="22" align="left">小计：{$currency_name}-税6%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax6']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax6']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="22" align="left">小计：{$currency_name}-税9%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax9']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax9']}</td>
						<td>&nbsp;</td>
					</tr>
				{/foreach}
				<tr class="lvtColData">
					<td colspan="22" align="left">合计：人民币-税0% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax0_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax0']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax0']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="22" align="left">合计：人民币-税6% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax6_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax6']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax6']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="22" align="left">合计：人民币-税9% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax9_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax9']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax9']}</td>
					<td>&nbsp;</td>
				</tr>
			{/if}
		{/foreach}
		
	{else}
		<tr class="lvtColData">
			<td colspan="25">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}

<!---- 运输---->
{if $YEWULEIXING eq '运输'}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1900px;">
	<tr>                       
		<th style="width:100px"><span title="费用单号">费用单号</span></th>
		<th style="width:80px"><span title="对接金蝶">对接金蝶</span></th>
		<th style="width:80px"><span title="对账状态">对账状态</span></th>
		<th style="width:80px"><span title="对接状态">对接状态</span></th>
		<th style="width:80px"><span title="业务分类">业务分类</span></th>
		<th style="width:200px"><span title="客户/供应商">客户/供应商</span></th>
		<th style="width:80px"><span title="JOB NO日期">JOB NO日期</span></th>
		<th style="width:100px"><span title="JOB NO">JOB NO</span></th>
		<th style="width:100px"><span title="JOB NO创建人">JOB NO创建人</span></th>
		<th style="width:150px"><span title="通关口岸">通关口岸</span></th>
		<th style="width:150px"><span title="收货人">收货人</span></th>
		<th style="width:150px"><span title="箱数/板数">箱数/板数</span></th>
		<th style="width:150px"><span title="数量">数量</span></th>
		<th style="width:150px"><span title="毛重">毛重</span></th>
		<th style="width:150px"><span title="运输单号">运输单号</span></th>
		<th style="width:150px"><span title="车型">车型</span></th>
		<th style="width:150px"><span title="车牌">车牌</span></th>
		<th style="width:150px"><span title="费用项目">费用项目</span></th>
		<th style="width:150px"><span title="税率">税率</span></th>
		<th style="width:150px"><span title="未税金额">未税金额</span></th>
		<th style="width:150px"><span title="含税金额">含税金额</span></th>
		<th style="width:150px"><span title="币种">币种</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td>{$row.billno}</td>
				<td>{$row.istoerp}</td>
				<td><span id="{$row.billid}_zhuangtai">{$row.zhuangtai}</span></td>
				<td><span id="{$row.billid}_kis_id">{if $row.kis_id gt 0}已对接{else}未对接{/if}</span></td>
				<td>{$row.yewufenlei}</td>
				<td>{$row.accountorvendor}</td>
				<td>{$row.jobno_date}</td>
				<td>{$row.jobno}</td>
				<td>{$row.jobno_creator}</td>
				<td>{$row.tongguankouan}</td>
				<td>{$row.shouhuoren}</td>
				<td>{$row.xiangshubanshu}</td>
				<td>{$row.qty}</td>
				<td>{$row.maozhong}</td>
				<td>{$row.yewudanhao}</td>
				<td>{$row.chexing}</td>
				<td>{$row.chepai}</td>
				<td>{$row.feiyongtype}</td>
				<td>{$row.shui}</td>
				<td>{$row.currency_symbol}{$row.weishui_amount}</td>
				<td>{$row.currency_symbol}{$row.hanshui_amount}</td>
				<td>{$row.currency_name}</td>
			</tr>
			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach key=$currency_name item=row from=$DATA['subtotal'][$row.accountorvendor]}
					<tr class="lvtColData">
						<td colspan="19" align="left">小计：{$currency_name}-税0%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax0']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax0']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="19" align="left">小计：{$currency_name}-税6%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax6']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax6']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="19" align="left">小计：{$currency_name}-税9%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax9']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax9']}</td>
						<td>&nbsp;</td>
					</tr>
				{/foreach}
				<tr class="lvtColData">
					<td colspan="19" align="left">合计：人民币-税0% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax0_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax0']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax0']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="19" align="left">合计：人民币-税6% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax6_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax6']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax6']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="19" align="left">合计：人民币-税9% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax9_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax9']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax9']}</td>
					<td>&nbsp;</td>
				</tr>
			{/if}
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="24">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}

<!---- 出入库---->
{if $YEWULEIXING eq '出入库'}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1900px;">
	<tr>                       
		<th style="width:100px"><span title="费用单号">费用单号</span></th>
		<th style="width:80px"><span title="对接金蝶">对接金蝶</span></th>
		<th style="width:80px"><span title="对账状态">对账状态</span></th>
		<th style="width:80px"><span title="对接状态">对接状态</span></th>
		<th style="width:80px"><span title="业务分类">业务分类</span></th>
		<th style="width:200px"><span title="客户/供应商">客户/供应商</span></th>
		<th style="width:80px"><span title="JOB NO日期">JOB NO日期</span></th>
		<th style="width:100px"><span title="JOB NO">JOB NO</span></th>
		<th style="width:100px"><span title="JOB NO创建人">JOB NO创建人</span></th>
		<th style="width:150px"><span title="品名">品名</span></th>
		<th style="width:150px"><span title="箱数/板数">箱数/板数</span></th>
		<th style="width:150px"><span title="数量">数量</span></th>
		<th style="width:150px"><span title="毛重">毛重</span></th>
		<th style="width:150px"><span title="运出入库单号">运出入库单号</span></th>
		<th style="width:150px"><span title="费用项目">费用项目</span></th>
		<th style="width:150px"><span title="税率">税率</span></th>
		<th style="width:150px"><span title="未税金额">未税金额</span></th>
		<th style="width:150px"><span title="含税金额">含税金额</span></th>
		<th style="width:150px"><span title="币种">币种</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td>{$row.billno}</td>
				<td>{$row.istoerp}</td>
				<td><span id="{$row.billid}_zhuangtai">{$row.zhuangtai}</span></td>
				<td><span id="{$row.billid}_kis_id">{if $row.kis_id gt 0}已对接{else}未对接{/if}</span></td>
				<td>{$row.yewufenlei}</td>
				<td>{$row.accountorvendor}</td>
				<td>{$row.jobno_date}</td>
				<td>{$row.jobno}</td>
				<td>{$row.jobno_creator}</td>
				<td>{$row.pinming}</td>
				<td>{$row.xiangshubanshu}</td>
				<td>{$row.qty}</td>
				<td>{$row.maozhong}</td>
				<td>{$row.yewudanhao}</td>
				<td>{$row.feiyongtype}</td>
				<td>{$row.shui}</td>
				<td>{$row.currency_symbol}{$row.weishui_amount}</td>
				<td>{$row.currency_symbol}{$row.hanshui_amount}</td>
				<td>{$row.currency_name}</td>
			</tr>
			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach key=$currency_name item=row from=$DATA['subtotal'][$row.accountorvendor]}
					<tr class="lvtColData">
						<td colspan="16" align="left">小计：{$currency_name}-税0%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax0']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax0']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="16" align="left">小计：{$currency_name}-税6%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax6']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax6']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="16" align="left">小计：{$currency_name}-税9%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax9']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax9']}</td>
						<td>&nbsp;</td>
					</tr>
				{/foreach}
				<tr class="lvtColData">
					<td colspan="16" align="left">合计：人民币-税0% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax0_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax0']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax0']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="16" align="left">合计：人民币-税6% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax6_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax6']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax6']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="16" align="left">合计：人民币-税9% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax9_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax9']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax9']}</td>
					<td>&nbsp;</td>
				</tr>
			{/if}
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="24">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}

<!---- 空运---->
{if $YEWULEIXING eq '空运'}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1900px;">
	<tr>                       
		<th style="width:100px"><span title="费用单号">费用单号</span></th>
		<th style="width:80px"><span title="对接金蝶">对接金蝶</span></th>
		<th style="width:80px"><span title="对账状态">对账状态</span></th>
		<th style="width:80px"><span title="对接状态">对接状态</span></th>
		<th style="width:80px"><span title="业务分类">业务分类</span></th>
		<th style="width:200px"><span title="客户/供应商">客户/供应商</span></th>
		<th style="width:80px"><span title="JOB NO日期">JOB NO日期</span></th>
		<th style="width:100px"><span title="JOB NO">JOB NO</span></th>
		<th style="width:100px"><span title="JOB NO创建人">JOB NO创建人</span></th>
		<th style="width:150px"><span title="航班日期">航班日期</span></th>
		<th style="width:150px"><span title="航班号">航班号</span></th>
		<th style="width:150px"><span title="主单号">主单号</span></th>
		<th style="width:150px"><span title="分单号">分单号</span></th>
		<th style="width:150px"><span title="计费重量">计费重量</span></th>
		<th style="width:150px"><span title="空运单号">空运单号</span></th>
		<th style="width:150px"><span title="费用项目">费用项目</span></th>
		<th style="width:150px"><span title="税率">税率</span></th>
		<th style="width:150px"><span title="未税金额">未税金额</span></th>
		<th style="width:150px"><span title="含税金额">含税金额</span></th>
		<th style="width:150px"><span title="币种">币种</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td>{$row.billno}</td>
				<td>{$row.istoerp}</td>
				<td><span id="{$row.billid}_zhuangtai">{$row.zhuangtai}</span></td>
				<td><span id="{$row.billid}_kis_id">{if $row.kis_id gt 0}已对接{else}未对接{/if}</span></td>
				<td>{$row.yewufenlei}</td>
				<td>{$row.accountorvendor}</td>
				<td>{$row.jobno_date}</td>
				<td>{$row.jobno}</td>
				<td>{$row.jobno_creator}</td>
				<td>{$row.real_flightdate}</td>
				<td>{$row.real_flightno}</td>
				<td>{$row.masterorder_no}</td>
				<td>{$row.fendanhao}</td>
				<td>{$row.jifeizhongliang}</td>
				<td>{$row.yewudanhao}</td>
				<td>{$row.feiyongtype}</td>
				<td>{$row.shui}</td>
				<td>{$row.currency_symbol}{$row.weishui_amount}</td>
				<td>{$row.currency_symbol}{$row.hanshui_amount}</td>
				<td>{$row.currency_name}</td>
			</tr>
			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach key=$currency_name item=row from=$DATA['subtotal'][$row.accountorvendor]}
					<tr class="lvtColData">
						<td colspan="17" align="left">小计：{$currency_name}-税0%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax0']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax0']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="17" align="left">小计：{$currency_name}-税6%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax6']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax6']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="17" align="left">小计：{$currency_name}-税9%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax9']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax9']}</td>
						<td>&nbsp;</td>
					</tr>
				{/foreach}
				<tr class="lvtColData">
					<td colspan="17" align="left">合计：人民币-税0% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax0_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax0']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax0']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="17" align="left">合计：人民币-税6% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax6_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax6']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax6']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="17" align="left">合计：人民币-税9% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax9_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax9']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax9']}</td>
					<td>&nbsp;</td>
				</tr>
			{/if}
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="24">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}

<!---- 海运---->
{if $YEWULEIXING eq '海运'}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1900px;">
	<tr>                       
		<th style="width:100px"><span title="费用单号">费用单号</span></th>
		<th style="width:80px"><span title="对接金蝶">对接金蝶</span></th>
		<th style="width:80px"><span title="对账状态">对账状态</span></th>
		<th style="width:80px"><span title="对接状态">对接状态</span></th>
		<th style="width:80px"><span title="业务分类">业务分类</span></th>
		<th style="width:200px"><span title="客户/供应商">客户/供应商</span></th>
		<th style="width:80px"><span title="JOB NO日期">JOB NO日期</span></th>
		<th style="width:100px"><span title="JOB NO">JOB NO</span></th>
		<th style="width:100px"><span title="JOB NO创建人">JOB NO创建人</span></th>
		<th style="width:150px"><span title="海运单号">海运单号</span></th>
		<th style="width:150px"><span title="费用项目">费用项目</span></th>
		<th style="width:150px"><span title="税率">税率</span></th>
		<th style="width:150px"><span title="未税金额">未税金额</span></th>
		<th style="width:150px"><span title="含税金额">含税金额</span></th>
		<th style="width:150px"><span title="币种">币种</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td>{$row.billno}</td>
				<td>{$row.istoerp}</td>
				<td><span id="{$row.billid}_zhuangtai">{$row.zhuangtai}</span></td>
				<td><span id="{$row.billid}_kis_id">{if $row.kis_id gt 0}已对接{else}未对接{/if}</span></td>
				<td>{$row.yewufenlei}</td>
				<td>{$row.accountorvendor}</td>
				<td>{$row.jobno_date}</td>
				<td>{$row.jobno}</td>
				<td>{$row.jobno_creator}</td>
				<td>{$row.yewudanhao}</td>
				<td>{$row.feiyongtype}</td>
				<td>{$row.shui}</td>
				<td>{$row.currency_symbol}{$row.weishui_amount}</td>
				<td>{$row.currency_symbol}{$row.hanshui_amount}</td>
				<td>{$row.currency_name}</td>
			</tr>
			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach key=$currency_name item=row from=$DATA['subtotal'][$row.accountorvendor]}
					<tr class="lvtColData">
						<td colspan="12" align="left">小计：{$currency_name}-税0%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax0']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax0']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="12" align="left">小计：{$currency_name}-税6%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax6']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax6']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="12" align="left">小计：{$currency_name}-税9%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax9']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax9']}</td>
						<td>&nbsp;</td>
					</tr>
				{/foreach}
				<tr class="lvtColData">
					<td colspan="12" align="left">合计：人民币-税0% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax0_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax0']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax0']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="12" align="left">合计：人民币-税6% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax6_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax6']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax6']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="12" align="left">合计：人民币-税9% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax9_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax9']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax9']}</td>
					<td>&nbsp;</td>
				</tr>
			{/if}
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="15">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}

<!---- Local配送---->
{if $YEWULEIXING eq 'Local配送'}
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1900px;">
	<tr>                       
		<th style="width:100px"><span title="费用单号">费用单号</span></th>
		<th style="width:80px"><span title="对接金蝶">对接金蝶</span></th>
		<th style="width:80px"><span title="对账状态">对账状态</span></th>
		<th style="width:80px"><span title="对接状态">对接状态</span></th>
		<th style="width:80px"><span title="业务分类">业务分类</span></th>
		<th style="width:200px"><span title="客户/供应商">客户/供应商</span></th>
		<th style="width:80px"><span title="JOB NO日期">JOB NO日期</span></th>
		<th style="width:100px"><span title="JOB NO">JOB NO</span></th>
		<th style="width:100px"><span title="JOB NO创建人">JOB NO创建人</span></th>
		<th style="width:150px"><span title="Local配送单号">Local配送单号</span></th>
		<th style="width:150px"><span title="费用项目">费用项目</span></th>
		<th style="width:150px"><span title="税率">税率</span></th>
		<th style="width:150px"><span title="未税金额">未税金额</span></th>
		<th style="width:150px"><span title="含税金额">含税金额</span></th>
		<th style="width:150px"><span title="币种">币种</span></th>
	</tr>
	{if $DATA['list']|@count neq 0}
		{foreach key=is_key item=row from=$DATA['list']}
			<tr class="lvtColData">
				<td>{$row.billno}</td>
				<td>{$row.istoerp}</td>
				<td><span id="{$row.billid}_zhuangtai">{$row.zhuangtai}</span></td>
				<td><span id="{$row.billid}_kis_id">{if $row.kis_id gt 0}已对接{else}未对接{/if}</span></td>
				<td>{$row.yewufenlei}</td>
				<td>{$row.accountorvendor}</td>
				<td>{$row.jobno_date}</td>
				<td>{$row.jobno}</td>
				<td>{$row.jobno_creator}</td>
				<td>{$row.yewudanhao}</td>
				<td>{$row.feiyongtype}</td>
				<td>{$row.shui}</td>
				<td>{$row.currency_symbol}{$row.weishui_amount}</td>
				<td>{$row.currency_symbol}{$row.hanshui_amount}</td>
				<td>{$row.currency_name}</td>
			</tr>

			{if $is_key|strpos:'sumtotal' neq ''}
				{foreach key=$currency_name item=row from=$DATA['subtotal'][$row.accountorvendor]}
					<tr class="lvtColData">
						<td colspan="12" align="left">小计：{$currency_name}-税0%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax0']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax0']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="12" align="left">小计：{$currency_name}-税6%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax6']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax6']}</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="lvtColData">
						<td colspan="12" align="left">小计：{$currency_name}-税9%</td>
						<td>{$row['currency_symbol']}{$row['weishui_amount_tax9']}</td>
						<td>{$row['currency_symbol']}{$row['hanshui_amount_tax9']}</td>
						<td>&nbsp;</td>
					</tr>
				{/foreach}
				<tr class="lvtColData">
					<td colspan="12" align="left">合计：人民币-税0% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax0_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax0']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax0']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="12" align="left">合计：人民币-税6% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax6_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax6']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax6']}</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="lvtColData">
					<td colspan="12" align="left">合计：人民币-税9% {$DATA['total'][$row.accountorvendor]['weishui_amount_tax9_label']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['weishui_amount_tax9']}</td>
					<td>¥{$DATA['total'][$row.accountorvendor]['hanshui_amount_tax9']}</td>
					<td>&nbsp;</td>
				</tr>
			{/if}
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="15">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>
{/if}

<script>
{literal}
	var windowWidth = document.documentElement.clientWidth;
    ld('.t-table').css('width', parseInt(windowWidth-20)+'px');
    ld('.t-table').css('height', parseInt(ld(window).height()-149)+'px');
{/literal}
</script>