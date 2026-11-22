{*<!-- Contents -->*}

{literal}
<style>
ul{
	padding:0px;
	list-style:none;
    margin-left:0px;
}
ul li{
	padding:2px 0px;
}
</style>
{/literal}

<div id='navigation' style="width:1000px; margin: 0px auto;">
    <div>
        <img src="themes/softed/images/{'INVENTORYMAP'|@getFixedLabel}" border="0" usemap="#Map" />
        <map name="Map" id="Map">
          <area shape="rect" coords="34,9,116,87" {$URL} title="{'ADMINISTRATOR'|@getFixedLabel}" />
          <area shape="rect" coords="159,85,243,160" {$URL} title="{'PROCUREMENTAUTHORITYUSER'|@getFixedLabel}" />
          <area shape="rect" coords="158,174,239,255" {$URL} title="{'LIBRARYUSERS'|@getFixedLabel}" />
          <area shape="rect" coords="163,260,237,336" {$WAREURL} title="{'WAREHOUSE'|@getFixedLabel}" />
          <area shape="rect" coords="159,349,238,423" {$URL} title="{'LIBRARYUSERPERMISSIONS'|@getFixedLabel}" />
          <area shape="rect" coords="157,432,247,512" {$URL} title="{'SALESOFUSER'|@getFixedLabel}" />
          <area shape="rect" coords="359,93,433,171" href="index.php?module=PurchaseOrder&action=index&parenttab=Purchase" title="{'PurchaseOrder'|@getTranstab}" />
          <area shape="rect" coords="361,180,433,255" href="index.php?module=Stock&action=index&parenttab=Stock" title="{'Stock'|@getTranstab}" />
          <area shape="rect" coords="359,261,443,336" href="index.php?module=Prdtnums&action=index&parenttab=Stock" title="{'Prdtnums'|@getTranstab}" />
          <area shape="rect" coords="359,341,440,424" href="index.php?module=OutboundOrder&action=index&parenttab=Stock" title="{'OutboundOrder'|@getTranstab}" />
          <area shape="rect" coords="358,439,441,521" href="index.php?module=SalesOrder&action=index&parenttab=Sales" title="{'SalesOrder'|@getTranstab}" />
          <area shape="rect" coords="534,206,608,293" href="index.php?module=WareHouseTransfer&action=index&parenttab=Stock" title="{'WareHouseTransfer'|@getTranstab}"  />
          <area shape="rect" coords="541,301,606,380" href="index.php?module=Checks&action=index&parenttab=Stock" title="{'Checks'|@getTranstab}" />
          <area shape="rect" coords="780,206,897,260" href="index.php?module=InventoryLedger&action=index&parenttab=Stock" title="{'InventoryLedger'|@getTranstab}" />
          <area shape="rect" coords="776,265,909,311" href="index.php?module=InventoryAccount&action=index&parenttab=Stock" title="{'InventoryAccount'|@getTranstab}" />
          <area shape="rect" coords="776,316,926,365" href="index.php?module=InventoryQuery&action=index&parenttab=Stock" title="{'InventoryQuery'|@getTranstab}" />
        </map>
    </div>
    <div style="font-size:12px;padding-left: 7%;">
        <p style="color:#F00;">{'APPLICATIONHINTS'|@getFixedLabel}</p>
        <div style="position:relative;float:left;color:#999"> 
        <ul>           
            <li><b>{'INVENTORYMANAGEMENT'|@getFixedLabel}</b>{'APPLICATIONPROCEDURE'|@getFixedLabel}</li>
            <li>{'THEFIRSTSTEPADMINSTRATOR'|@getFixedLabel}</li>
            <li>{'THESECONDSTEPFROMPRODUCT'|@getFixedLabel}</li>
           <br/>
            <li><b>{'THEPURCHASE'|@getFixedLabel}</b>{'APPLICATIONPROCEDURE'|@getFixedLabel}</li>
            <li>{'THEORDERFILLEDINBYTHEPURCHASER'|@getFixedLabel}</li>
            <li>{'THEPROCUREMENTSTAFFGENERAION'|@getFixedLabel}</li>
           <li> {'THETHIRDSTEOPACTUALDELIVERYCON'|@getFixedLabel}</li>    
           </ul>      
        </div>
        <div style="position:relative;float:left;color:#999;margin-left:20px;">
             <ul>
                <li><b>{'SALEOUTBOUNDORDER'|@getFixedLabel}</b>{'APPLICATIONPROCEDURE'|@getFixedLabel}</li>
                <li>{'THEFIRSTSTEPCONTRACTSALES'|@getFixedLabel}</li>
                <li>{'THESECONDPERSONACCORDINGTOCONTRACT'|@getFixedLabel}</li>
                <li>{'THETHIRDRECEPITCIONFIRMED'|@getFixedLabel}</li>
                <br/>
                <li><b>{'BANKTRANSFER'|@getFixedLabel}</b>{'APPLICATIONPROCEDURE'|@getFixedLabel}{'PICKUP'|@getFixedLabel}</li>
                <li>{'THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSE'|@getFixedLabel}</li>
                <li>{'THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSE'|@getFixedLabel}</li>
                <li><b>{'BANKTRANSFER'|@getFixedLabel}</b>{'APPLICATIONPROCEDURE'|@getFixedLabel}{'DELIVERY'|@getFixedLabel}</li>
                <li>{'THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSEOUT'|@getFixedLabel}</li>
                <li>{'THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSEOUT'|@getFixedLabel}</li>
            </ul>
        </div>
    </div>
    <img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}">
</div>        