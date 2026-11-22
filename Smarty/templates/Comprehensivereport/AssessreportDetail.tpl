<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售统计表——按考核</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:20px;}
.DivBox_top { width:100%; height:45px;}
.DivBox_top h1 { float:left; font-size:20px; color:#666; line-height:30px;}
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:8px;}
.Find_box table { background:#ccc;}
.Find_box table td { background:#fff;}
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%; background:url(themes/softed/images/layerPopupBg.gif) repeat left 0px;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}

.Find_Form0 .Select { float:left; width:150px; height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px; line-height:20px;}

.Find_Form0 .Div0 { float:left;position:relative; z-index:1;}
.Find_Form0 input.Button_find { margin-left:10px;}
/*---查找 end----*/
/*---蓝色保存-小按钮---*/
.Button_find { float:left; color:#fff;font-weight:bold; overflow:hidden; line-height:21px;border:none;padding: 0 15px; border-radius:3px; cursor:pointer; font-size:12px; background-image: url(themes/softed/images/toolbar-bg.png);}

/*---绿色保存-大按钮---*/
.DivBox_Center { width:100%; overflow:hidden; padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; overflow:hidden;}
.DivBox_Center .DivList0 table { background:#ccc;}
.DivBox_Center .DivList0 table th,.DivBox_Center .DivList0 table td { background:#fff; font-size:13px; color:#666; line-height:24px; padding:3px 10px;}
.DivBox_Center .DivList0 table th { background:#C7D9EE url(themes/softed/images/thbj.png) repeat-x left 0px; color:#2A66C5; padding:5px 10px;/* font-weight:lighter;*/}
.DivBox_Center .DivList0 table tr.Bj td { background:#EEF7FF;}
.DivBox_Center .DivList0 table tr.ZBj td { background:#FFFFC1;}
.DivBox_Center .DivList0 table tr td.Blackbj { background:#f6f6f6; vertical-align:top; font-weight:bold;}
.DivBox_Center .DivList0 table tr.Hover:hover td { background:#FFFFE8;}
.DivBox_Center .DivList0 table tr.Hover:hover td.Blackbj { background:#f6f6f6;}

.align-r{text-align:right;}
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        {if $MONTH != 0}
            <h1>{$YEAR}年{$MONTH}月销售员考核统计报表:</h1>
        {else}
            <h1>{$YEAR}年销售员考核年度统计报表:</h1>
        {/if}
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<!--table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0">
                	<h3>查找</h3>
                	<label class="Name">初期：</label>
                    
                    <label class="Name">期末：</label>
                    
                    <label class="Name">人员名：</label>
                    <select class="Select">
                    	<option>人员名</option>
                        <option>人员名</option>
                    </select>
                    <input type="button" value="查询" class="Button_find" />
                </form>
            </td>
          </tr>
        </table-->
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th rowspan='2'>序号</th>
                        <th rowspan='2'>销售员</th>
                        <th colspan="3">销售额(元)</th>
                        <th rowspan='2'>资金回笼(元)</th>
                        <th rowspan='2'>退货金额(元)</th>
                        <th rowspan='2'>有效资金回笼(元)</th>
                        <th rowspan='2'>有效资金回笼占比</th>
                        <th rowspan='2'>应收余额(元)</th>
                        <th rowspan='2'>有效布点数量</th>
                        <th rowspan='2'>费用(元)</th>
                        <th rowspan='2'>费用占比</th>      
                    </tr>
                    <tr>
                        <td style="background-color:#C7D9EE;color:#2a66c5;font-weight:bold;">新布点金额</td>
                        <td style="background-color:#C7D9EE;color:#2a66c5;font-weight:bold;" >返单</td>
                        <td style="background-color:#C7D9EE;color:#2a66c5;font-weight:bold;" >合计</td> 
                    </tr>
                    
                    {foreach name=countRow from=$ASSESS_LIST key=key item=arr}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                    <tr>
                       {foreach from=$arr key=key2 item=arr2}
                       {if $key2==1 || $key2==2}
                       <td class="listTableRow" style="background-color:#EEF7FF;">
                       {else}
                       <td class="align-r" style="background-color:#EEF7FF;">
                       {/if}
                       {$arr2}
                       </td>
                       {/foreach}
                    </tr>
                    {else}
                    <tr>
                       {foreach from=$arr key=key2 item=arr2}
                       {if $key2==1 || $key2==2}
                       <td class="listTableRow">
                       {else}
                       <td class="align-r">
                       {/if}
                       {$arr2}
                       </td>
                       {/foreach}
                    </tr>
                    {/if}
                    {/foreach}
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>