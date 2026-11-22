<form name='marketlead' method="POST" enctype="multipart/form-data"  action="index.php">
    <input  type="hidden" name="action" value='Save'/>
    <input  type="hidden" name="module" value='PromotionSetting'/>
    <div class="d_box">
      <ul>
        <li class="d_box_title">设置基本参数</li>
        <li>
          <input name="status" checked="checked" type="checkbox" {if $STATUS eq 'yes'} checked=""{/if}>
          <span>启用</span><input  type="button" value="保存" onclick="marketleadsetsave()"/>
        </li>
        <li>
          <input name="bussiness_allocate" checked="checked" value="partner" type="radio" {if $BUSSINESS_ALLOCATE eq 'partner'} checked=""{/if}>
          获取商机自动分配给推广伙伴
          <input name="bussiness_allocate" value="2" {if $BUSSINESS_ALLOCATE neq 'partner'} checked=""{/if} type="radio">
          获取的商机统一给
          <select name="bussiness_allocate_userid">
            
            {foreach key=userid from=$USERS  item=usernames} 
              {foreach key=name from=$usernames  item=foo}
                 <option value="{$userid}"  {if $BUSSINESS_ALLOCATE eq $userid} selected=""{/if}>{$name}</option>
              {/foreach}
            {/foreach}   
          </select>
        </li> 
        <li>
          <span>
            商机成交标识
            <select name="bussinessdeal_condition">
              <option value="SalesOrder" {if $BUSSINESSDEAL_CONDITION eq 'SalesOrder'} selected=""{/if}>签订合同订单</option>
              <option value="Approve:SalesOrder" {if $BUSSINESSDEAL_CONDITION eq 'Approve:SalesOrder'} selected=""{/if}>鉴定合同订单并审核通过</option>
              <option value="ServiceContracts" {if $BUSSINESSDEAL_CONDITION eq 'ServiceContracts'} selected=""{/if}>签订服务合同</option>
              <option value="Approve:ServiceContracts" {if $BUSSINESSDEAL_CONDITION eq 'Approve:ServiceContracts'} selected=""{/if}>签订服务合同并审核通过</option>
              <option value="SalesOrder:ServiceContracts"{if $BUSSINESSDEAL_CONDITION eq 'SalesOrder:ServiceContracts'} selected=""{/if} >签订合同或者服务合同</option>
              <option value="Approve:SalesOrder:ServiceContracts" {if $BUSSINESSDEAL_CONDITION eq 'Approve:SalesOrder:ServiceContracts'} selected=""{/if}>签订合同订单或者服务合同并审核通过</option>
            </select>
          </span>
        </li>
        <li>
          <span>我的商机首次成交获得红包返点方式</span>
          <select name='marketmethod1'>
            <option value="fixed" {if  $first_COMMISSIONMETHOD eq 'fixed'} selected=""{/if}>固定金额</option>
            <option value="percent" {if  $first_COMMISSIONMETHOD eq 'percent'} selected=""{/if}>首笔签约金额比例</option>
          </select>
          <input style="width:50px;" value="{$first_COMMISSIONMONEY}" type="text" name="marketmoney1">
        </li>
        <li>
          <span>直属下级商机首次成交获得红包返点方式</span>
          <select name='marketmethod2'>
           <option value="fixed" {if  $second_COMMISSIONMETHOD eq 'fixed'} selected=""{/if}>固定金额</option>
            <option value="percent" {if  $second_COMMISSIONMETHOD eq 'percent'} selected=""{/if}>首笔签约金额比例</option>
          </select>
          <input style="width:50px;" value="{$second_COMMISSIONMONEY}" type="text" name="marketmoney2">
        </li>
        <li>
          <span>推广平台管理员</span>
          <select name='marketadminuser'>
           {foreach key=userid from=$USERS  item=usernames} 
              {foreach key=name from=$usernames  item=foo}
              
                 <option value="{$userid}" {if $MARKETADMINUSER eq $userid} selected=""{/if}>{$name}</option>
              {/foreach}
            {/foreach}   
          </select>
        </li>
      </ul>
    </div>
    
    <div class="d_box">
      <ul>
        <li class="d_box_title">设置商机字段以及商机和销售线索字段的映射关系</li>    
      </ul>
      <table id="Importtable" class="listEntries unset-overf" style="border-collapse:separate;" width="100%" cellspacing="1" cellpadding="0">
        <tbody>
          <tr>
            <th style="padding-right:10%" width="30%">商机字段</th>
            <th style="padding-right:20%" width="13%">字段属性</th>
            <th style="padding-right:16%" width="13%">是否启用</th>
            <th style="padding-right:20%" width="14%">是否必录项</th>
            <th style="padding-right:20%" width="30%">映射字段</th>
          </tr>
          {foreach from=$MARKETFIELDS  key=k   item=marketfieldinfo}
                  <tr class="fieldIdentifier lvtColData">
                    <td>
                      <input style="width:80%;" value="{$marketfieldinfo->fieldlabel}" type="text" name='marketfieldlabel{$k}' id='marketfieldlabel{$k}'>
                      <input style="width:80%;" value="{$marketfieldinfo->marketfieldname}" type="hidden" name='marketfieldname{$k}' id='marketfieldname{$k}'>
                    </td>
                    <td>
                       {if $marketfieldinfo->typeofdata  eq 'V~O' || $marketfieldinfo->typeofdata  eq 'V~M' }
                        文本
                        {else if $marketfieldinfo->typeofdata  eq 'C~O' || $marketfieldinfo->typeofdata  eq 'C~M'}
                            下拉框
                        
                       {/if}
                    </td>
                    <td>
                        {if $marketfieldinfo->marketfieldname  eq 'accountname' || $marketfieldinfo->marketfieldname eq 'mobile'}
                         <input checked="checked" type="checkbox" disabled="true" >
                         <input  type="hidden" value="1" name="marketfieldpresence{$k}" id="marketfieldpresence{$k}"/>
                        {else}
                            {if $marketfieldinfo->presence eq 'yes' }
                                <input checked="checked" type="checkbox" onchange="checkPresence(this)" name="marketfieldpresence{$k}" id="marketfieldpresence{$k}">
                            {else}
                                <input  type="checkbox" onchange="checkPresence(this)" name="marketfieldpresence{$k}" id="marketfieldpresence{$k}">
                            {/if}
                        {/if}
                     
                    </td>
                    <td>
                         {if $marketfieldinfo->marketfieldname  eq 'accountname' || $marketfieldinfo->marketfieldname eq 'mobile'}
                         <input checked="checked" type="checkbox" disabled="true" >
                         <input  type="hidden" value="1" name="marketfieldtypeofdata{$k}" id="marketfieldtypeofdata{$k}"/>
                        {else}
                            {if $marketfieldinfo->typeofdata eq 'C~M'|| $marketfieldinfo->typeofdata eq 'V~M' }
                                <input checked="checked" type="checkbox" onchange="checkMust(this)" name="marketfieldtypeofdata{$k}" id="marketfieldtypeofdata{$k}">
                            {else}
                                <input  type="checkbox" onchange="checkMust(this)" name="marketfieldtypeofdata{$k}" id="marketfieldtypeofdata{$k}">
                            {/if}
                        {/if}
                    </td>
                    <td>
                     
                      <select name="marketleadfield{$k}" id="marketleadfield{$k}">
                        {foreach from=$LEADFIELD item=fieldinfo}
                        
                            {if $fieldinfo->getDisplaytype()  eq '1'  ||$fieldinfo->getDisplaytype()  eq '4'|| $fieldinfo->getDisplaytype()==''}
                                {if $fieldinfo->getColumnName() eq $marketfieldinfo->columnname}
                                   
                                        <option value="{$fieldinfo->getFieldName()}" selected="">{$fieldinfo->getfieldLabel()}</option>
                                    
                                {else}
                                    {if $marketfieldinfo->typeofdata eq 'C~O'|| $marketfieldinfo->typeofdata eq 'C~M' }
                                        {if $fieldinfo->getUIType() eq 15 }
                                            <option value="{$fieldinfo->getFieldName()}">{$fieldinfo->getfieldLabel()}</option>
                                        {/if}
                                    {else}
                                        <option value="{$fieldinfo->getFieldName()}">{$fieldinfo->getfieldLabel()}</option>
                                    {/if}
                                {/if}
                            {/if}
                        {/foreach}    
                      </select>
                    </td>
                  </tr>
          {/foreach}
        
          
        </tbody>
      </table>
    </div>
    
    <div class="d_box">
      <ul>
        <li class="d_box_title">定制推广页面头部图片</li>
        <li>
          <div>
            <img src="{$TEMPLATEPATH}" style="width: 320px;height: 220px">
          </div>
        </li> 
        <li>
        <input  type="hidden" value="{$TEMPLATEPATH}" name="templatepath"/>
          <input type="file" name="img" />
        </li>    
      </ul>
    </div>

</form>
<script type="text/javascript">
{literal}
    function marketleadsetsave()
    {
        //
        for(var i=0;i<=100;i++)
        {
           
            if(document.getElementById('marketfieldpresence'+i)!=undefined&&document.getElementById('marketfieldpresence'+i)!='undefined')
            {
               
             
               if(document.getElementById('marketfieldpresence'+i).checked&&document.getElementById('marketleadfield'+i).options.selectedIndex<=0)
               {
                
                    alert(document.getElementById('marketfieldlabel'+i).value+"没有映射字段！");
                    return false;
               }  
               if(trim(document.getElementById('marketfieldlabel'+i).value)=='')
               {
                    alert("第"+i+"行第一列值不能为空！");
               }
            }
            else
            {
                break;
            }
        }
        document.forms['marketlead'].submit();
    }
    function checkMust(obj)
    {
        
        var parentobj=obj.parentNode||obj.parentElement;
        var parentrowobj=parentobj.parentNode||parentobj.parentElement;
        var rowindex=parentrowobj.rowIndex;
         if(obj.checked)
          {
            var idindex=rowindex-1;
          
            document.getElementById("marketfieldpresence"+idindex).checked=true;
          }
       
    }
    function checkPresence(obj)
    {
      var parentobj=obj.parentNode||obj.parentElement;
      var parentrowobj=parentobj.parentNode||parentobj.parentElement;
      var rowindex=parentrowobj.rowIndex;
       if(!obj.checked)
          {
            var idindex=rowindex-1;
          
            document.getElementById("marketfieldtypeofdata"+idindex).checked=false;
          }
      
    }
{/literal}

</script>