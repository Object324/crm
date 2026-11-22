<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售统计表——按省份</title>
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
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%; background:url(themes/softed/image/layerPopupBg.gif) repeat left 0px;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 input.Input_time { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 input.Bjffd { background:#ffd;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 input.Input_Text { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 .Select { float:left; width:150px; height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px; line-height:20px;}
.Find_Form0 input.Checkbox { float:left; margin:4px 0px 0px 10px; *margin-top:0px;}
.Find_Form0 .Div0 { float:left;position:relative; z-index:1;}
.Find_Form0 .Div0:hover .Input_Text { background:#ffd;}
.Find_Form0 ul.Change { display:none; float:left; position:absolute; width:200px; left:0px; top:21px; z-index:2; border:1px #ddd solid; background:#fff; padding:10px;}
.Find_Form0 ul.Change li { float:left; width:50%; padding:2px 0px; border-bottom:1px #ddd solid;}
.Find_Form0 ul.Change li input { float:left; margin-top:3px; *margin-top:0px;}
.Find_Form0 ul.Change li label { float:left; font-size:12px; color:#666; line-height:20px; padding-left:5px;}
.Find_Form0 .Div0:hover ul.Change { display:block;}
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

.Forms-Forms { width:100%;font-family:Arial, Helvetica, sans-serif;}
.Forms-Forms .tableName{ color: #999999;font-family: 黑体;font-size: 15pt;margin-bottom:10px;}
.Forms-Forms  table { width:95%; border-top:1px solid #dedede; border-left:1px solid #dedede; border-collapse: collapse;}
.Forms-Forms  table tr td{ padding:0 5px; border-bottom:1px solid #dedede; border-right:1px solid #dedede; margin:0; font-size:12px; line-height:30px; }
.T-Color{ background:#7B95C7;text-align:center;font-weight:bold;color:#fff;}
.Forms-Forms  table tr td.Bgimg { background:url(thead_bg.png) repeat-x; font-size:14px; font-weight:bold; color:#555;}
.Forms-Forms  table tr td.Alone { background:#c0d3df;}

.Forms-Forms { width:100%;font-family:Arial, Helvetica, sans-serif;}
.Forms-Forms .tableName{ color: #999999;font-family: 黑体;font-size: 15pt;margin-bottom:10px;}
.Forms-Forms  table { width:100%; border-top:1px solid #dedede; border-left:1px solid #dedede; border-collapse: collapse;}
.Forms-Forms  table tr td{ padding:0 5px; border-bottom:1px solid #dedede; border-right:1px solid #dedede; margin:0; font-size:12px; line-height:30px; }
.T-Color{ background:#7B95C7;text-align:center;font-weight:bold;color:#fff;}
.Forms-Forms  table tr td.Bgimg { background:url(thead_bg.png) repeat-x; font-size:14px; font-weight:bold; color:#555;}
.Forms-Forms  table tr td.Alone { background:#c0d3df;}
.listTableRowBlank2{text-indent:24px;}
.listTableRowBlank4{text-indent:60px;}
.listTableRowRight{text-align:right;}
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$year}{$YEAR}年{$MONTH}月销售统计表——按省份:</h1>
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
                        <th >省份</th>
                        <th >本月销售(元)</th>
                        <th >同比增长</th>
                        <th >本年累计(元)</th>
                        <th >同比增长</th>
                        <th >网点数量</th>
                        <th >网点平均销售(元)</th>
                        <th >返单网点数量</th>
                        <th >资金回笼(元)</th>
                        <th >回笼占比</th>
                        <th >应收余额(元)</th>          
                    </tr>
                    {foreach name=countRow from=$THISMONTHLIST key=key item=arr}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                        <tr>
                           {foreach  from=$arr key=key2 item=arr2}
                           {if $key2==1}
                           <td class="listTableRow" style="background-color:#EEF7FF;">
                           {else}
                           <td class="listTableRowRight" style="background-color:#EEF7FF;" >
                           {/if}
                           {$arr2}
                           </td>
                           {/foreach}
                        </tr>
                    {else}
                        <tr>
                           {foreach  from=$arr key=key2 item=arr2}
                           {if $key2==1}
                           <td class="listTableRow">
                           {else}
                           <td class="listTableRowRight">
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