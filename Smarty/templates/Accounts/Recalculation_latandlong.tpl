<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Accounts"/>
    <input type="hidden" name="action" value ="Recalculation_latandlong"/>
	<input type="hidden" name="have_address_records" value ="{$HAVE_ADDRESS_RECORDS}"/>
	<input type="hidden" name="have_address_and_no_latandlong_records" value ="{$HAVE_ADDRESS_AND_NO_LATANDLONG_RECORDS}"/>
	<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
			<tr>
				<td class="ld-form-item-content padL0 select-input">
					<div>
						<input type="radio" class="marB-1" name="radio_recalculation" checked value="part" id="radio_recalculation_part"><label for="radio_recalculation_part">{$HAVE_ADDRESS_AND_NO_LATANDLONG_RECORDS_DESC}</label>
					</div>
					<div class="padT16">
						<input type="radio" class="marB-1" name="radio_recalculation" value="all" id="radio_recalculation_all"><label for="radio_recalculation_all">{$HAVE_ADDRESS_RECORDS_DESC}</label>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</form>