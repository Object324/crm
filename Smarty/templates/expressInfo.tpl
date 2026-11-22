<div class="trendview" >
	<div class="topnews"
	<div class="box" style="max-height: 500px;overflow: auto;">
		<ul class="event_list" >
			<div>
				{*                    <h3>快递单号：{$EXPRESS_INFO.nu}</h3>*}
				{foreach item=data from=$EXPRESS_INFO.data}
					<li>
						<div class="div_p" style="width: 95%;">
							<div class="div_span">
								<div class="">
									<div style="float: left;margin-right: 20px; font-weight: bold;">状态：{$data.statusDetail}</div>
									<div><b ><br></b></div>
									<div style="margin-right: 10px;">{$data.time} </div><div>  {$data.context}</div>
								</div>
							</div>
					</li>
				{/foreach}
			</div>
		</ul>
	</div>
</div>
