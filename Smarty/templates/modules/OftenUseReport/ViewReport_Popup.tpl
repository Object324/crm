{literal}
<style>

* { margin: padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:5px;}
.DivBox_top { width:100%; height:35px;}
.DivBox_top h1 { float:left; font-size:20px; color:#000; line-height:30px;}
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:0px;}
/*.Find_box table { background:#ccc;}*/
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:130px;float:left;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 label.Name span{margin-right:5px;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 .Select { float:left; width:150px; height:22px; line-height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px;}

.DivBox_Center { width:100%; overflow:hidden; padding:5px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; overflow:hidden;}
</style>
{/literal}
<div class="D_pop_tit">
	<strong class="D_ptita">{'Schoolrecorddetails'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('DivPopupReport');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th style="text-align:center;" width="40">#</th>
                        <th>{'ClassDates'|@getFixedLabel}</th>
                        <th>{'ClassName'|@getFixedLabel}</th>
                        <th>{'StudentName'|@getFixedLabel}</th>
                    </tr>
                    {if $ViewList |@count >0}
                    {foreach name=countRow key =key item =result from =$ViewList}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                        <tr class="Hover">
                            <td align="center">{$smarty.foreach.countRow.index+1}</td>
                            <td>{$result.closingdate}</td>
                            <td>{$result.productname}</td>
                            <td>{$result.lastname}</td>
                        </tr>
                    {else}
                        <tr class="Bj Hover">
                            <td align="center">{$smarty.foreach.countRow.index+1}</td>
                            <td>{$result.closingdate}</td>
                            <td>{$result.productname}</td>
                            <td>{$result.lastname}</td>
                        </tr>
                    {/if}
                    
                    {/foreach}
                    {else}
                    <tr>
                        <td colspan="5" style="background-color:#FFF;height:340px">
                            <div class='noResultBG' >   		 
                               <div class='noResultContent'> 
                            		<div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                               </div>      
                            </div>
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>