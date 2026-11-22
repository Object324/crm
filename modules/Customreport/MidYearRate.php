<?php
/**
* reason:联合技术报表：Mid-Year Rate Adjustment
* eidt:xiaoshun
* date:2016-09-21
**/

global $adb,$theme;
global $current_user;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";

$_REQUEST['GARate1'] = isset($_REQUEST['GARate1'])?$_REQUEST['GARate1']:'6.7';
$_REQUEST['GARate2'] = isset($_REQUEST['GARate2'])?$_REQUEST['GARate2']:'7.2';
$_REQUEST['LaborRate1']= isset($_REQUEST['LaborRate1'])?$_REQUEST['LaborRate1']:'98.0';
$_REQUEST['LaborRate2']=isset($_REQUEST['LaborRate2'])?$_REQUEST['LaborRate2']:'101.5';
$str_date = isset($_REQUEST['search_date'])?$_REQUEST['search_date']:date('Y-m-d',time());

//为空取0
$GARate1 = $_REQUEST['GARate1']==''?0:$_REQUEST['GARate1'];
$GARate2 = $_REQUEST['GARate2']==''?0:$_REQUEST['GARate2'];
$LaborRate1 = $_REQUEST['LaborRate1']==''?0:$_REQUEST['LaborRate1'];
$LaborRate2 = $_REQUEST['LaborRate2']==''?0:$_REQUEST['LaborRate2'];

$time_date = strtotime($str_date);

$smarty->assign('GARATE1',$GARate1);
$smarty->assign('GARATE2',$GARate2);
$smarty->assign('LABORRATE1',$LaborRate1);
$smarty->assign('LABORRATE2',$LaborRate2);
$smarty->assign('SEARCHDATE',$str_date);


if(!isset($_REQUEST['month'])){
    //Summary
    $month = intval(date('m',$time_date));
    $sql = "SELECT a.po_no,";
    for($i=1;$i<=$month-1;$i++){
        $endstr = $i!=$month-1?',':''; 
        $sql .= "ifnull(b".$i.".rate_adj,'0.00') as ".$i."_adj".$endstr;
    }
    
    $sql .= " from (
    	select 
    	DISTINCT po_no
    	from vw_costinvoice
    	where date BETWEEN  '".date('Y-01-01',$time_date)."' 
    				and date_sub('".$str_date."',interval extract(day from '".$str_date."') day)
    	order by po_no) a";
        
    for($i=1;$i<=$month-1;$i++){
        $sql .= " LEFT JOIN (
    		SELECT
    		po_no,
    		LaborOH2+AdjGA2+TScharge2+up10_2-(LaborOH1+AdjGA1+TScharge1+up10_1) as rate_adj 
    		from (
    				select
    				year(date) nian,
    				MONTH(date) yue,
    				po_no,
    				round(sum(laborcost),2) laborcost,
    				round(sum(travel),2) travel,
    				0 as other,
    				round(round(sum(laborcost),2)*$LaborRate1*0.01,2) as LaborOH1,
    				round((round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate1*0.01)*$GARate1*0.01,2) as 'AdjGA1',
    				0 as 'TScharge1',
    				round((round(sum(laborcost),2)
    					+round(sum(travel),2)
    					+round(sum(laborcost),2)*$LaborRate1*0.01
    					+(round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate1*0.01)*$GARate1*0.01
    				 )*0.10,2) as 'up10_1',
    				round(sum(laborcost)*$LaborRate2*0.01,2) as LaborOH2,
    				round((round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate2*0.01)*$GARate2*0.01,2) as 'AdjGA2',
    				0 as 'TScharge2',
    				round((round(sum(laborcost),2)
    					+round(sum(travel),2)
    					+round(sum(laborcost),2)*$LaborRate2*0.01
    					+(round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate2*0.01)*$GARate2*0.01+0)*0.10,2) as 'up10_2'
    				from vw_costinvoice
    				where date BETWEEN '".date('Y-01-01',$time_date)."' 
    					and date_sub('".$str_date."',interval extract(day from '".$str_date."') day)
    				group by po_no,year(date),MONTH(date)) a
    		where a.nian=".date('Y',$time_date)."
    			and a.yue=$i) b$i on b$i.po_no=a.po_no";
    }
    
    $sql .= ' order by a.po_no';

    $result = $adb->pquery($sql);
    
    $num_rows=$adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $data[$i][] = $adb->query_result($result,$i,'po_no');
        for($j=1;$j<=$month-1;$j++){
            $data[$i][] = number_format($adb->query_result($result,$i,$j.'_adj'),2);
        }
    }
    
    
    $table = '<table class="rptTable TableOften" cellspacing="0" cellpadding="0">';
    //第一行
    $table .='<tr style="background:#CCCCFF;">';
    $table .='<td align="center" style="width:90px;font-family:Tahoma;font-size:7pt;font-weight:bold;line-height:15px;padding:5px">IDWA# / Line #</td>';
    for($i = 1; $i<=$month-1; $i++){
        $table .='<td align="center" style="width:60px;font-family:Tahoma;font-size:7pt;font-weight:bold;line-height:15px;padding:5px">' . date('M',strtotime('2016-'.$i)) . ' Adj</td>';
    }
    $table .='<td align="center" style="width:60px;font-family:Tahoma;font-size:7pt;font-weight:bold;line-height:15px;padding:5px">Total Adj</td>';
    $table .='</tr>';
    $all_total = 0;
    for($i=0;$i<$num_rows;$i++){
        $total_val = 0;
        $table .= '<tr>';
        foreach($data[$i] as $key=>$val){
            if($key == 0){
                //第1列PO.NO显示为蓝色字体
                $table .= '<td align="center" style="width:60px;font-family:Tahoma;font-size:8pt;color:#2A5FFF">'.$val.'</td>';
                $total[$key] = 'Total';
            }
            else{
                //如果$val显示为红色，等于0显示为-
                if($val<0){
                   $table .= '<td title="view details" align="center" style="width:60px;font-family:Tahoma;font-size:8pt"><a style="color:red" href="javascript:;" onclick="view_month('.$key.')">'.number_format($val,2).'</a></td>'; 
                }
                elseif($val==0){
                   $table .= '<td title="view details" align="center" style="width:60px;font-family:Tahoma;font-size:8pt">-</td>'; 
                }
                else{
                    $table .= '<td title="view details" align="center" style="width:60px;font-family:Tahoma;font-size:8pt"><a href="javascript:;" onclick="view_month('.$key.')">'.number_format($val,2).'</a></td>';           
                }
                $total[$key] += $val;
                $total_val += $val;     //小计
                $all_total += $val;     //总计
            }
        }
        
        if($total_val<0){
            //如果合计小于0显示为红色
            $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold;color:red">'.$total_val.'</td>';
        }else{
            $table .= '<td align="center" style="width:60px;font-family:Arial;font-weight:bold;font-size:8pt">'.$total_val.'</td>';
        }
        $table .= '</tr>';
    }  
    
    $table .= '<tr>';

    //行合计
    foreach($total as $key=>$val){
        if($key == 0){
            //第一行以黑色加粗显示 Total
            $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold">'.$val.'</td>';
        }else{
            //如果合计小于0显示为红色,合计等于0时不显示超链接
            if($val<0){
              $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold;"><a title="view details" style="color:red" href="javascript:;" onclick="view_month('.$key.')">'.number_format($val,2).'</a></td>';  
            }
            if($val==0){
              $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold;">0.00</td>';  
            }else{
                $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold;"><a title="view details" href="javascript:;" onclick="view_month('.$key.')">'.number_format($val,2).'</a></td>';
            }
        }
        
    }
    
    //总合计
    //如果总合计小于0则显示为红色，总合计没有超链接
    if($all_total<0){
        $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold;color:red">'.number_format($all_total,2).'</td>';
    }else{
        $table .= '<td align="center" style="width:60px;font-family:Arial;font-size:8pt;font-weight:bold">'.number_format($all_total,2).'</td>';
    }
    $table .= '</tr>';
    $table .= '</table>';
    $smarty->assign('SHOWHEADER','yes');
}else{
    //月明细
    $view_month = $_REQUEST['month'];
    $month_sql = "SELECT
            nian,
            yue,
            po_no,
            laborcost,
            travel,
            other,
            LaborOH1,
            AdjGA1,
            TScharge1,
            up10_1,
            laborcost+travel+other+LaborOH1+AdjGA1+TScharge1+up10_1 as 'total1',
            LaborOH2,
            AdjGA2,
            TScharge2,
            up10_2,
            laborcost+travel+other+LaborOH2+AdjGA2+TScharge2+up10_2 as 'total2',
            LaborOH2+AdjGA2+TScharge2+up10_2-(LaborOH1+AdjGA1+TScharge1+up10_1) as rate_adj 
            from (
            		select
            		year(date) nian,
            		MONTH(date) yue,
            		po_no,
            		round(sum(laborcost),2) laborcost,
            		round(sum(travel),2) travel,
            		'0.00' as other,
            		round(sum(laborcost)*$LaborRate1*0.01,2) as LaborOH1,
            		round((round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate1*0.01)*$GARate1*0.01,2) as 'AdjGA1',
            		'0.00' as 'TScharge1',
            		round((round(sum(laborcost),2)
 			           +round(sum(travel),2)
 			           +round(sum(laborcost),2)*$LaborRate1*0.01
            			+(round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate1*0.01)*$GARate1*0.01
            		)*0.10,2) as 'up10_1',
            		round(round(sum(laborcost),2)*$LaborRate2*0.01,2) as LaborOH2,
            		round((round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate2*0.01)*$GARate2*0.01,2) as 'AdjGA2',
            		'0.00' as 'TScharge2',
            		round((round(sum(laborcost),2)
            			+round(sum(travel),2)
            			+round(sum(laborcost),2)*$LaborRate2*0.01
            			+(round(sum(laborcost),2)+round(sum(travel),2)+round(sum(laborcost),2)*$LaborRate2*0.01)*$GARate2*0.01+0)*0.10,2) as 'up10_2'
            		from vw_costinvoice
            		where date BETWEEN '".date('Y-01-01',$time_date)."' 
            			and date_sub('".$str_date."',interval extract(day from '".$str_date."') day)
            		group by po_no,year(date),MONTH(date)) a
            where 	a.nian= ".date('Y',$time_date)."
            		and a.yue=$view_month
            order by po_no";
            
            $result = $adb->pquery($month_sql);
            $num_rows=$adb->num_rows($result);

            for($i=0;$i<$num_rows;$i++){
                $month_data[] = array(
                    'po_no' => $adb->query_result($result,$i,'po_no'),
                    'laborcost' => $adb->query_result($result,$i,'laborcost'),
                    'travel' => $adb->query_result($result,$i,'travel'),
                    'other' => $adb->query_result($result,$i,'other'),
                    'LaborOH1' => $adb->query_result($result,$i,'laboroh1'),
                    'AdjGA1' => $adb->query_result($result,$i,'adjga1'),
                    'TScharge1' => $adb->query_result($result,$i,'tscharge1'),
                    'up10_1' => $adb->query_result($result,$i,'up10_1'),
                    'total1' => $adb->query_result($result,$i,'total1'),
                    'empty1' => '',
                    'LaborOH2' => $adb->query_result($result,$i,'laboroh2'),
                    'AdjGA2' => $adb->query_result($result,$i,'adjga2'),
                    'TScharge2' => $adb->query_result($result,$i,'tscharge2'),
                    'up10_2' => $adb->query_result($result,$i,'up10_2'),
                    'total2' => $adb->query_result($result,$i,'total2'),
                    'empty2' => '',
                    'rate_adj' => $adb->query_result($result,$i,'rate_adj')
                );
            }
            
            
            $table = '<table  border="1" cellspacing="0" cellpadding="0" style="line-height:20px">';
            
            //第一行
            $table .= '<tr>';
            $table .= '<td colspan="4" style="border-top:none;border-bottom:none;border-left:none;border-right:none"></td>';
            $table .= '<td align="center" colspan="5"><font style="font-family:Arial;font-size:10pt;font-weight:bold">Org Plan Rates</font></td>';
            $table .= '<td style="border-top:none;border-bottom:none;"></td>';
            $table .= '<td align="center" colspan="5"><font style="font-family:Arial;font-size:10pt;font-weight:bold">New Rates</font></td>';
            $table .= '<td align="center" style="border-top:none;border-bottom:none;border-right:none"></td>';
            $table .= '</tr>';
            
            //第二行
            $table .= '<tr>';
            $table .= '<td colspan="4" style="border-top:none;border-left:none;border-right:none"><font style="font-family:Tahoma;font-size:8pt;font-weight:bold">Currency: USD</font></td>';
            $table .= '<td align="center" style="border-left:none;border-right:none"><font style="font-family:Tahoma;font-size:7pt;font-weight:bold;color:red">'.$LaborRate1.'%</font></td>';
            $table .= '<td align="center" style="border-left:none;border-right:none"><font style="font-family:Tahoma;font-size:7pt;font-weight:bold;color:red">'.$GARate1.'%</font></td>';
            $table .= '<td align="center" colspan="3" style="border-left:none;border-right:none"></td>';
            $table .= '<td align="center" style="border-top:none;border-left:none;border-right:none"></td>';
            $table .= '<td align="center" style="border-left:none;border-right:none"><font style="font-family:Tahoma;font-size:7pt;font-weight:bold;color:red">'.$LaborRate2.'%</font></td>';
            $table .= '<td align="center" style="border-left:none;border-right:none"><font style="font-family:Tahoma;font-size:7pt;font-weight:bold;color:red">'.$GARate2.'%</font></td>';
            $table .= '<td align="center" colspan="3" style="border-left:none;border-right:none"></td>';
            $table .= '</tr>';
            
            //列头
            $table .='<tr style="background:#CCCCFF;">';
            $header_array = array(
                                'IDWA# / Line #',
                                'Labor Cost',
                                'Travel Related',
                                'Others',
                                'Labor OH @'.$LaborRate1.'%',
                                'Adj G&A @'.$GARate1.'%',
                                'Tax and Surcharge',
                                'Mark-up (10%)',
                                'Total Prev Billed',
                                '',
                                'Labor OH @'.$LaborRate2.'%',
                                'Adj G&A @'.$GARate1.'%',
                                'Tax and Surcharge',
                                'Mark-up (10%)',
                                'New Total',
                                '',
                                'Rate Adjustment'
                            );
  
            foreach($header_array as $val){
                $table .='<td align="center" style="white-space:normal;width:65px;font-family:Tahoma;font-size:7pt;font-weight:bold;line-height:15px;padding:5px">'.$val.'</td>';
            }
            
            $table .='</tr>';
        
            //列表内容
            for($i=0;$i<$num_rows;$i++){
                $table .= '<tr>';
                foreach($month_data[$i] as $key=>$val){
                    if($key == 'po_no'){
                        $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt;color:#2A5FFF">'.$val.'</td>';
                    }
                    elseif($key == 'laborcost'){
                        $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt;color:#2A5FFF">'.number_format($val,2).'</td>';
                    }
                    elseif($key == 'travel' or $key == 'other' ){
                        $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt;color:#2A5FFF">'.number_format($val,2).'</td>';
                    }
                    elseif($key == 'rate_adj'){
                        //若金额小于0显示为红色，若等于0显示为-
                        if($val<0){
                            $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt;color:red">'.number_format($val,2).'</td>';   
                        }
                        elseif($val==0){
                            $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt">'-'</td>';   
                        }               
                        else{
                            $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt">'.number_format($val,2).'</td>';
                        }
                    }
                    else{
                        $table .= '<td align="center" style="font-family:Tahoma;font-size:8pt">'.number_format($val,2).'</td>';
                    }
                    
                }
                $table .= '</tr>';
            }
            $smarty->assign('OFMONTH',date('F',strtotime('2016-'.$view_month)));
         
}

$smarty->assign('REPORTFILTERHTML',$table);
$smarty->display('MidYearRate.tpl');
?>