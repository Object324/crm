<div>
	<table cellpadding="2" cellspacing="0" width="100%" align="center" border=0 style="background:#F4F4F4;">
		<tr>
			<td align="center" class="small" width=90% style="vertial-align:bottom">
				<div style="overflow:auto;background-color: #fff;max-height:315px;" name='pop_adv_filter_div'>
					<div style="width: 100%;">
						<ul class="test_ul" style="padding-left: 8px;">
							<li style="width: 25%;"><div>{'Select_field'|@getFixedLabel}</div></li>
							<li style="width: 20%;"><div>{'SELECTIONCRITERIA'|@getFixedLabel}</div></li>
							<li style="width: 30%;"><div>{'SEARCHKEY'|@getFixedLabel}</div></li>
							<li style="float:right;width: 90px;"><div id="advfiltershow" style="display: none;">{'SCREENINGRELATIONSHIP'|@getFixedLabel}</div></li>
						</ul>
					</div>
					<table class="settingPopTable lasttdbordernon" name="conditiongrouptable_1" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
						<tr name="groupheader"></tr>
						<tr name='groupfooter'>
							<td colspan='5' align='left' class='padTB5'>
								<a id='addbtn' href='javascript:void(0);'>{'NEWCONDITIONS'|@getFixedLabel}</a>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
			</td>
		</tr>
	</table>
</div>