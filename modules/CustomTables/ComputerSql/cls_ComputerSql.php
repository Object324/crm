<?php
class cls_ComputerSql
{
    public $type;
    public $asfixedname;
    public $typevalue_arr;
    public $module_arr;
    public $fieldsAlias;
    public $computertext;
    public $computerfun;
    public $computercolumn_arr;
    public $fields;
    public $typevalue;
    public $isdistinct;
    public $selectModuleTable_arr ;
    public $istotal;
    public $totalcompupterText;//所有行的合计标签名称
    public $detailviewobj;

    public function __construct($detailviewobj)
    {
        $this->detailviewobj=$detailviewobj;
    
        $this->asfixedname=$detailviewobj->asfixedname;
        $this->typevalue_arr=$detailviewobj->typevalue_arr;
        $this->module_arr=$detailviewobj->module_arr;
        $this->fieldsAlias=$detailviewobj->fieldsAlias;
        $this->fields=$detailviewobj->fields;
        $this->isdistinct='no';//唯一计数用到了
        $this->selectModuleTable_arr=[];
        $this->istotal='no';
    }
    
    public function setIstotal($istotal)
    {
        //表示获取总计行yes:是 no:否
        $this->istotal=$istotal;
    }


    public function getSumColumns($allsumcolum_arr,$groupby_arr){
        $totalvalueColumn_arr=[];
        $totalcolumnName_arr=[];
        $totalcolumnfieldinfo_arr=[];
        $computerfun_arr=['avg','max','sum','min'];
        $summodule='';
        $conditionSql_columnarr = [];//这些字段要放到conditionsql中去查询
        //所有需要统计的字段数组Array([0] => ld_sendcashbill:total:hdnGrandTotal:SendCashBill_合计:N)
        foreach($allsumcolum_arr as $tmpcolumninfo)
        {
            $column_arr=explode(":",$tmpcolumninfo);
            $tablename=$column_arr[0];
            $columnname=$column_arr[1];
            $module_arr=explode("_",$column_arr[3]);
            $tmpmodulename=$module_arr[0];
            $totalvalueColumn_arr[]=$tablename.$this->asfixedname.$columnname;
            $totalcolumnName_arr[]=$tablename.'.'.$columnname;

            $tmpfocus=CRMEntity::getInstance($tmpmodulename);
            $summodule=$tmpmodulename;
            if(in_array($tablename,$tmpfocus->tab_name))
            {
                $fieldinfo=$tmpfocus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
            }
            else{

                $fieldinfo=$tmpfocus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);
            }
            $totalcolumnfieldinfo_arr[]=$fieldinfo;

        }
        $sumfocus=CRMEntity::getInstance($summodule);
        $sumtablename=$sumfocus->table_name;

        $groupvalueColumn_arr=[];
        $groupcolumnName_arr=[];
        $grouptableName_arr=[];//分组字段所在的表名
        $allgroupfieldinfo_arr=[];
        //分组字段
        foreach($this->detailviewobj->groupcolumn_arr as $groupindex=>$groupcolumninfo)
        {
            $tmp_arr= explode(":",$groupcolumninfo);
            $tmp_grouptablename=$tmp_arr[0];
            $tmp_columnname=$tmp_arr[1];
            $tmp_arr=explode("_",$tmp_arr[3]);
            $tmp_groupmodule=$tmp_arr[0];
            $tmp_focus=CRMEntity::getInstance($tmp_groupmodule);
            if(in_array($tmp_grouptablename,$tmp_focus->tab_name))
            {
                $fieldinfo=$tmp_focus->fieldobj->getFieldInfoobjBykey("columnname",$tmp_columnname);

            }
            else
                $fieldinfo=$tmp_focus->detailfieldobj->getFieldInfoobjBykey("columnname",$tmp_columnname);
            $allgroupfieldinfo_arr[]=$fieldinfo;
        }

        $allgroupfieldlen=sizeof($allgroupfieldinfo_arr);
        foreach($groupby_arr as $tmpcolumninfo)
        {
            $column_arr=explode(":",$tmpcolumninfo);
            $tablename=$column_arr[0];
            $columnname=$column_arr[1];
            $groupvalueColumn_arr[]=$tablename.$this->asfixedname.$columnname;
            $groupcolumnName_arr[]=$tablename.'.'.$columnname;
            $grouptableName_arr[]=$tablename;
            $module_arr=explode("_",$column_arr[3]);

            $this->selectModuleTable_arr[$module_arr[0]][]=$tablename;

        }
        $groupcolumnLen=sizeof($groupcolumnName_arr);
        if($this->istotal=='yes')
        {
            $groupcolumnName_arr[$groupcolumnLen-1]=" '".$this->totalcompupterText."' ";
        }
        else
            $groupcolumnName_arr[$groupcolumnLen-1]=" concat(".$groupcolumnName_arr[$groupcolumnLen-1].",'-".$this->computertext."')";

        $column_arr=[];

        foreach($this->detailviewobj->fieldsAlias as $tmpindex=>$fieldalia)
        {
            //zxm 20220720 _order字段增加小计
            if(stripos($fieldalia,$this->detailviewobj->ordercolumn_suff)!=FALSE&&$this->detailviewobj->show_detail!='yes'){
                $columnname_tmp = $this->fields[$tmpindex];
                $columnname_tmp_arr = explode('as',$columnname_tmp);
                $columnname = ' concat('.$columnname_tmp_arr[0].'-'.$this->totalcompupterText.')';
                $column_arr[$tmpindex]=" $columnname as $fieldalia ";
            }

            if(in_array($fieldalia,$totalvalueColumn_arr))
            {
                $columnname=$totalcolumnName_arr[array_search($fieldalia,$totalvalueColumn_arr)];
                $fieldinfo=$totalcolumnfieldinfo_arr[array_search($fieldalia,$totalvalueColumn_arr)];
                if($this->isdistinct=='yes')
                {
                    $column_arr[$tmpindex]=$this->computerfun. "( distinct  $columnname) as $fieldalia ";
                    if($tmpindex==0)
                    {
                        if($this->istotal=='yes')
                        {
                            $column_arr[$tmpindex]=' concat("'.$this->totalcompupterText.'",'.$this->computerfun. "( distinct  $columnname)) as $fieldalia ";
                        }
                        else
                            // $column_arr[$tmpindex]=" CONCAT_WS(".$columnname.',"'.$this->computertext.'",'.$this->computerfun. "( distinct  $columnname)) as $fieldalia ";
                            $column_arr[$tmpindex]=$this->computerfun. "( distinct  $columnname) as $fieldalia ";


                    }
                }
                else
                {

                    $columnmodule = $this->detailviewobj->column_arr[$tmpindex]['columnmodule'];
                    //zxm 20221027 设置的求和字段是产品表的字段 没有币种符号的----20230816 zxm明细表的加税合计也要这个汇率转换
                    //zxm 20231130 customform26没有币种转换  需要判断
                    if(($fieldinfo->getBigType()=='currency'||$fieldinfo->getBigType()=='amount')
                        &&in_array(trim($this->computerfun),$computerfun_arr)
                        &&$fieldinfo->getTableName()!='ld_products'
                        &&!empty($columnmodule)
                        &&isHaveCurrrencyColumn($columnmodule))
                    {
                        //币种转换汇率
                        //$column_arr[$tmpindex]=' concat("¥",'.$this->computerfun. "($columnname/ifnull($sumtablename.conversion_rate,1))) as $fieldalia ";
                        $fieldalia_arr = explode('belong',$fieldalia);
                        $column_arr[] = ' "¥" as '.$fieldalia_arr[0].'currency_symbol';
                        $column_arr[$tmpindex]=$this->computerfun. "(ifnull($columnname,0)/ifnull($sumtablename.conversion_rate,1)) as $fieldalia ";
                    }
                    else
                        $column_arr[$tmpindex]=$this->computerfun. "($columnname) as $fieldalia ";
                    if($tmpindex==0)
                    {
                        if($this->istotal=='yes')
                        {
                            $column_arr[$tmpindex]=' concat("'.$this->totalcompupterText.'",'.$this->computerfun. "(   $columnname)) as $fieldalia " ;
                        }
                        else
                            $column_arr[$tmpindex]=$this->computerfun. "(   $columnname) as $fieldalia " ;


                    }
                }

            }
            else if(in_array($fieldalia,$groupvalueColumn_arr))
            {
                $columnname=$groupcolumnName_arr[array_search($fieldalia,$groupvalueColumn_arr)];
                //zxm 20231010 分组字段拼接小计/分组字段/模块主键ID/汇率需要从conditionsql中来--start
                /*$columnname=$groupvalueColumn_arr[array_search($fieldalia,$groupvalueColumn_arr)];
                if($this->istotal=='yes')
                {
                    $columnname=" '".$this->totalcompupterText."' ";
                }
                else
                    $columnname="concat(conditionSql.".$columnname.",'-".$this->computertext."')";*/
                //zxm 20231010 分组字段拼接小计/分组字段/模块主键ID/汇率需要从conditionsql中来--end
                $column_arr[$tmpindex]="$columnname as $fieldalia ";
            }
            else if(in_array($fieldalia,$this->detailviewobj->ordercolumn_arr))
            {
                //$column_arr[$tmpindex]=$this->fields[$tmpindex];
                //zxm 20231010这里处理的字段是为了排序用,比如客户编号加了-小计,排序会有问题,所以特意加个字段没有-小计的用来排序使用--start
                $fieldalia_arr = explode($this->detailviewobj->asfixedname,$fieldalia);
                if(in_array($fieldalia_arr[0],$grouptableName_arr)){
                    $column_arr[$tmpindex]=$this->fields[$tmpindex];
                }else if($sumtablename==$fieldalia_arr[0]){
					//条件SQL中只有主键ID  没有其他字段
                    $columnname=$this->fields[$tmpindex];
                    $columnname_arr=explode('.',$columnname);
                    $tmpfieldalia = str_replace($this->detailviewobj->ordercolumn_suff,'',$fieldalia);
                    $column_arr[$tmpindex] = 'conditionSql.'.$tmpfieldalia.' as '.$fieldalia;

                }else{
                    $column_arr[$tmpindex]="' ' as $fieldalia ";
                }

                //这里处理的字段是为了排序用,比如客户编号加了-小计,排序会有问题,所以特意加个字段没有-小计的用来排序使用--end

                if($allgroupfieldlen>1)
                {
                    $tmpsearch_index=array_search($fieldalia,$this->detailviewobj->ordercolumn_arr);
                    $tmpfieldidnfo=$allgroupfieldinfo_arr[$tmpsearch_index];

                    if($tmpsearch_index==$allgroupfieldlen-1&&$tmpfieldidnfo->getBigType()=='reference'&&sizeof($groupby_arr)==1)
                    {
                        $tmpasvalue=999999999999;

                        $column_arr[$tmpindex]=" $tmpasvalue  as   " .$fieldalia;
                    }
                }


            }
            else if(is_array($this->detailviewobj->fieldsCurrencySymbol)&& in_array($fieldalia,$this->detailviewobj->fieldsCurrencySymbol)){
                $column_arr[$tmpindex]="'¥' as $fieldalia ";
            }else if(in_array($this->detailviewobj->fields[$tmpindex],$this->detailviewobj->tableIndexFieldArr)){
                $fieldalia_arr = explode($this->detailviewobj->asfixedname,$fieldalia);
                if(in_array($fieldalia_arr[0],$grouptableName_arr)){
                    $columnname=$groupcolumnName_arr[array_search($fieldalia,$groupvalueColumn_arr)];
                    $column_arr[$tmpindex] = $this->detailviewobj->fields[$tmpindex];
                }else{
                    //zxm 20231010 这里处理的字段是排序字段所在表的主键
                    $column_arr[$tmpindex] = 'conditionSql.'.$fieldalia.' as '.$fieldalia;
                }
            }else{
                $column_arr[$tmpindex]="' ' as $fieldalia ";
            }
        }
        $sumgrouptype=$this->typevalue_arr[$this->typevalue];
        $sumgrouptype=intval($sumgrouptype);
        $column_arr[]="$sumgrouptype AS type";
        $column_arr[]="'".$this->typevalue."' AS type_desc";
        $focus=CRMEntity::getInstance($this->detailviewobj->mainmodule);
        $tablename=$focus->table_name;
        $tableindex=$focus->table_index;
        $column_arr[]=" 0 AS maintableindex";//主模块是客户，次模块是销售机会 ，使用次模块的销售机会 两个字段（按照次模块的自定义表字段分组）

        return  implode(",",$column_arr);


    }
    public function getGroupBySumSql()
    {
        global $adb;
         $usedgroupcolumn_arr=[];//['module'=>'','column'=>'','tablename'=>''];
        $grouptablecolumn_arr=[];
       
        $asfixedname=$this->asfixedname;
         $group_sql_arr=[];
         $sql_arr=[];
         $summoduleInfo=[];
         $summoduleInfo_arr=[];
        foreach($this->computercolumn_arr as $sumindex=>$sumcolumninfo )
        {
            $sumcolumn_arr=explode(":",$sumcolumninfo);
            $tmp_arr=explode("_",$sumcolumn_arr[3]);
            $summodule=$tmp_arr[0];
            $sumtablename=$sumcolumn_arr[0];
            $sumcolumn=$sumcolumn_arr[1];
            $sumfocus=CRMEntity::getInstance($summodule);
            $fieldtype='detail';
            if(array_key_exists($sumtablename,$sumfocus->tab_name_index))
            {
                $fieldtype='main';
            }
            $summoduleInfo_arr[$summodule][$fieldtype][]=$sumcolumninfo;
            
        }
       
        $existgroupbyColumn_arr=[];
        $asfixedname=$this->asfixedname;
       
        foreach($this->detailviewobj->groupcolumn_arr as $tmpindex=> $groupcolumninfo  )
        {
              
            //分组用union all 
            $total_sql_arr=[];
            $existgroupbyColumn_arr[]=$groupcolumninfo;
            $groupcolumn_arr=explode(":",$groupcolumninfo);
            $tmp_arr=explode("_",$groupcolumn_arr[3]);
            $groupmodule=$tmp_arr[0];
            $groupbytablename=$groupcolumn_arr[0];
            $groupbycolumn= $groupcolumn_arr[1];
            
            //分组字段
            $usedgroupcolumn_arr[]=['module'=>$groupmodule,'tablename'=>$groupcolumn_arr[0],'column'=>$groupcolumn_arr[1],'columninfo'=>$groupcolumninfo];
            $groupfocus=CRMEntity::getInstance($groupmodule);

            if(in_array($groupbytablename,$groupfocus->customFieldTable))
            {
                $sql=" update $groupbytablename set $groupbycolumn='' where $groupbycolumn is null  ";
                $adb->pquery($sql,array());//两个group by 字段一个主表，一个自定义表字段用ifnull非常慢
                $grouptablecolumn_arr[]=$groupbytablename.'.'.$groupbycolumn;
            }
            else
            $grouptablecolumn_arr[]=" ifnull( ".$groupbytablename.'.'.$groupbycolumn.',"")';

            $sql_totalcolumn_arr=[];
            foreach($summoduleInfo_arr as $summodule=>$fieldsumcolumninfo )
            {
               if(array_key_exists('main',$fieldsumcolumninfo))
               {
                     $selectcolumns=$this->getSumColumns($fieldsumcolumninfo['main'],$existgroupbyColumn_arr);
                  
                    $sql_totalcolumn_arr[]=$fieldsumcolumninfo['main'];
                  
                    $groupjoinsql= $this->setgroupbysqlnew($usedgroupcolumn_arr,$fieldsumcolumninfo['main']);
                 //   dump($groupjoinsql);
                    $tmpkey=sizeof($sql_arr);

                    if($this->istotal=='yes')
                    {
                        $total_sql_arr[]="select $selectcolumns   from $groupjoinsql  ";
                    }
                    else
                        $total_sql_arr[]="select $selectcolumns   from $groupjoinsql group by ". implode(',',$grouptablecolumn_arr);


                }
                
                if(array_key_exists('detail',$fieldsumcolumninfo)){

                    //分录字段计算
                    $selectcolumns=$this->getSumColumns($fieldsumcolumninfo['detail'],$existgroupbyColumn_arr);
                        $sql_totalcolumn_arr[]=$fieldsumcolumninfo['detail'];
                        
                     
                        $groupjoinsql= $this->setgroupbysqlnew($usedgroupcolumn_arr,$fieldsumcolumninfo['detail']);
                    $tmpkey=sizeof($sql_arr);
                        if($this->istotal=='yes')
                        {
                            $total_sql_arr[]="select $selectcolumns   from $groupjoinsql  ";
                        }
                        else
                            $total_sql_arr[]="select $selectcolumns   from $groupjoinsql group by ". implode(',',$grouptablecolumn_arr);

                }
                 

            }

            $this->typevalue_arr[$this->typevalue]=intval($this->typevalue_arr[$this->typevalue])-1;
            $sql_totaltablename_arr=[];
            
             $tmpi=0;
            $tmptablename="temp$tmpindex$tmpi";
            $sql="(".$total_sql_arr[$tmpi]. ") as $tmptablename";
            $sql_totaltablename_arr[$tmpi]=$tmptablename;
           if(sizeof($total_sql_arr)>1)
                $sql='';
            $totalsqllen=sizeof($total_sql_arr);
           
            for($tmpi=0;$tmpi<$totalsqllen;$tmpi++)
            { 
                 $tmpjoin='';
                if($tmpi>=1)
                {
                    $tmpjoin=' left join ';
                    $previndex=$tmpi;
                    
                     $tmpi++;
                     $nextidex=$tmpi;
                    
                }
                else{
                    $previndex=$tmpi;
                    $nextidex=$tmpi+1;
                }
              
                 
                 $onsql_arr=[];
                 $tmptablename="temp$tmpindex$previndex";
                $sql_totaltablename_arr[$previndex]=$tmptablename;
                $nexttmptablename="temp$tmpindex$nextidex";
                if($tmpi<sizeof($total_sql_arr)-1)
                {

                    $sql.=" $tmpjoin (".$total_sql_arr[$previndex]. ") as $tmptablename left join (" .$total_sql_arr[$nextidex].") as $nexttmptablename";
                    $sql.=" on ";

                    $sql_totaltablename_arr[$nextidex]=$nexttmptablename;
                    foreach($usedgroupcolumn_arr as $tmpinfo)
                    {
                        $tablename=$tmpinfo['tablename'];
                        $columnname=$tmpinfo['column'];
                        $onsql_arr[]=" ifnull( $tmptablename.$tablename$asfixedname$columnname".$this->detailviewobj->ordercolumn_suff.",'')=ifnull($nexttmptablename.$tablename$asfixedname$columnname".$this->detailviewobj->ordercolumn_suff.",'')";
                    }
                }
                else if($tmpi<$totalsqllen&&$totalsqllen>1){
                  
                   $sql_totaltablename_arr[$nextidex]=$nexttmptablename;
                   $sql.=" $tmpjoin (".$total_sql_arr[$nextidex]. ") as $nexttmptablename on  ";
                  
                     foreach($usedgroupcolumn_arr as $tmpinfo)
                    {
                        $tablename=$tmpinfo['tablename'];
                        $columnname=$tmpinfo['column'];
                        $onsql_arr[]=" ifnull( $tmptablename.$tablename$asfixedname$columnname".$this->detailviewobj->ordercolumn_suff.",'')=ifnull($nexttmptablename.$tablename$asfixedname$columnname".$this->detailviewobj->ordercolumn_suff.",'') ";
                    } 
                }

                if(sizeof($onsql_arr)>0)
                    $sql.=implode(" and ",$onsql_arr);


            }

            
            $firsttemptablename=$sql_totaltablename_arr[0];
            $fieldAlia_arr=$this->fieldsAlias;
            
            foreach($sql_totalcolumn_arr as $totalindex=>$totalcolumninfo_arr)
            {
                $temptablename=$sql_totaltablename_arr[$totalindex];
                foreach($totalcolumninfo_arr as $totalcolumninfo)
                {
                    $totalcolumn_arr=explode(":",$totalcolumninfo);
                    $columnname=$totalcolumn_arr[1];
                    $tablename=$totalcolumn_arr[0];
                    $ascolumnname=$tablename.$this->asfixedname.$columnname;
                  
                    if(in_array($ascolumnname,$fieldAlia_arr))
                    {
                        $fieldAlia_arr[array_search($ascolumnname,$fieldAlia_arr)]=$temptablename.'.'.$ascolumnname;
                        
                    }
                    else{
                        
                    }
                }
            }
           
            foreach($fieldAlia_arr as &$columnname)
            {
                if(strpos($columnname,'.')!==false)
                {
                    
                }
                else{
                    $columnname=$firsttemptablename.'.'.$columnname;
                }
            }
            $fieldAlia_arr[]=$firsttemptablename.'.type ';
            $fieldAlia_arr[]=$firsttemptablename.'.type_desc ';
            $fieldAlia_arr[]=$firsttemptablename.'.maintableindex ';

            $sql="  (select " .implode(",",$fieldAlia_arr).' from '.$sql.' ) ' ;
            $group_sql_arr[]=$sql;
            $this->detailviewobj->group_sql_statistic[trim($this->computerfun)][$groupcolumninfo] = $sql;//zxm20220719 改成数组返回
            $sql='';
            if($this->istotal=='yes')
            {
                break;
            }
            
        }
        
         //分组用union all
         return implode(' union all ' ,$group_sql_arr);
    }

    public function setgroupbysqlnew($usedgroupcolumn_arr,$suminfo_arr)
    {
        //from 子句包含sum ,group 的column所在的表
        $groupmodule_arr=[];
        $sumtable_arr=[];
        foreach($suminfo_arr as $sumindex=>$suminfo)
        {
            //求出合计字段和合计字段所在的表
            $sum_arr=explode(":",$suminfo);
            $summodule_arr=explode("_",$sum_arr[3]);
            $summodule=$summodule_arr[0];
            $sumfocus=CRMEntity::getInstance($summodule);
            if($sum_arr[0]!=$sumfocus->table_name)
            {
                $sumtable_arr[]=$sum_arr[0];
            }
        }

        $grouptable_arr=[];


        foreach($this->detailviewobj->groupcolumn_arr as $tmpinfo)
        {
            //跨模块分组字段  排序要使用另外一个模块的字段
            $tmpinfo_arr=explode(":",$tmpinfo);
            $tmpmodule_arr=explode("_",$tmpinfo_arr[3]);
            $groupmodule_arr[]=$tmpmodule_arr[0];
            if(!in_array($tmpinfo_arr[0],$sumtable_arr))
                $sumtable_arr[]=$tmpinfo_arr[0];

        }
        $endrightjionsql = '';
        $conditionsql2on = '';
        $conditionsql2ongroupby = '';
        $conditionsql2table = '';



        $prevmodules =$this->detailviewobj->module_arr['prevSelectedArr'];//所有的模块 上游模块
        $nextmodules = $this->detailviewobj->module_arr['nextSelectedArr'];//所有的模块 下游模块
        $allmodules = array_merge($nextmodules, $prevmodules);//所有的模块 排列顺序是主模块 下游模块 上游模块
        $summoduleindex = array_search($summodule,$allmodules);

        foreach ($allmodules as $tmpmodule_index => $tmpmodulename) {
            foreach ($usedgroupcolumn_arr as $tmpusedIndex => $tmpusedgroupinfo) {
                if ($tmpusedgroupinfo['module'] == $tmpmodulename && !in_array($tmpmodulename, $grouptable_arr)) {
                    $grouptable_arr[] = $tmpusedgroupinfo['tablename'];
                    $groupbyfocus = CRMEntity::getInstance($tmpusedgroupinfo['module']);
                    //zxm 20231010 统计模块和分组模块是同一个模块的话 最后不需要重复连同一个表
                    if ($summodule == $tmpusedgroupinfo['module']) {

                    } else {
                        $tmpjiontype = ' right join ';
                        if(in_array($tmpusedgroupinfo['module'],$prevmodules)){
                            $tmpjiontype = ' left join ';//如果分组字段是上游模块的 应当是left join
                        }
                        //zxm 20240815 BUG20240814-20  主模块客户 下游模块选出库单  按客户自定义字段行业分组 求和出库单合计
                        $tmpusedgroupinfotablename = $tmpusedgroupinfo['tablename'];
                        if($tmpusedgroupinfo['tablename']==$groupbyfocus->customFieldTable[0]){
                            $tmpusedgroupinfotablename = $groupbyfocus->table_name;
                        }
                        $endrightjionsql = $tmpjiontype . $tmpusedgroupinfo['tablename'] . ' on ' . $tmpusedgroupinfo['tablename'] . '.' . $groupbyfocus->table_index . '=conditionSql.' . $tmpusedgroupinfotablename . $this->detailviewobj->asfixedname . $groupbyfocus->table_index;
                        $conditionsql2on = $tmpusedgroupinfo['tablename'] . '.' . $groupbyfocus->table_index . '=conditionSql2.' . $tmpusedgroupinfotablename . $this->detailviewobj->asfixedname . $groupbyfocus->table_index;
                        $conditionsql2table = $tmpusedgroupinfo['tablename'];
                        $conditionsql2ongroupby = $tmpusedgroupinfotablename . '.' . $groupbyfocus->table_index;
                    }


                }
            }
        }

        foreach($this->detailviewobj->groupcolumn_arr as $tmpinfo)
        {
            $tmptable_arr= explode(":",$tmpinfo);
            if(!in_array($tmptable_arr[0],$grouptable_arr))
                $grouptable_arr[]=$tmptable_arr[0];
        }
        $lengroupmodule=sizeof($groupmodule_arr);
        $firstgroupbymoduleindex=array_search($groupmodule_arr[0],$allmodules);
        $lastgroupbymoduleindex=array_search($groupmodule_arr[$lengroupmodule-1],$allmodules);

        $groupjoinsql='';
        $hadtable_arr=[];

        for($i=$summoduleindex;$i>$firstgroupbymoduleindex;$i--)
        {
            if($i-1>=0)
            {

            }
            else{
                break;
            }

            $curmodule=$allmodules[$i-1];

            $nextmodule=$allmodules[$i];
            $curfocus=CRMEntity::getInstance($curmodule);
            $nextfocus=CRMEntity::getInstance($nextmodule);
            
            $tablejoinobj= cls_TableJoin_module::getInstance($curmodule,$nextmodule);

            $groupjoinsql_arr=$tablejoinobj->getJoin();



          //  $hadtable_arr=array_merge($groupjoinsql_arr['jointable'],$hadtable_arr);
                 
            if($i==$summoduleindex)
            {
                //$groupjoinsql.=$nextfocus->table_name;//zxm 20231010
                //zxm 20240815 BUG20240814-20  主模块客户 下游模块选出库单  按客户自定义字段行业分组 求和出库单合计
                $groupjoinsql .= $curfocus->table_name;
                $hadtable_arr[] = $curfocus->table_name;
                $groupjoinsql .= $groupjoinsql_arr['joinsqltype'].' '.$groupjoinsql_arr['joinsql'];
                $hadtable_arr = array_merge($hadtable_arr,$groupjoinsql_arr['jointable']);

                $summaintablename=$sumfocus->table_name;
                $sumtableindex=$sumfocus->table_index;
                $sumDetail_table_index=$sumfocus->Detail_table_index;
                $Detail_table=$sumfocus->Detail_table;
                $Detail_table_scf=$sumfocus->Detail_table_scf;
                $Detail_table_id=$sumfocus->Detail_table_id;
                //$hadtable_arr[]=$nextfocus->table_name;

                if(in_array($sumfocus->Detail_table,$groupjoinsql_arr['jointable'])&&!in_array($summaintablename,$hadtable_arr))
                {
                    //分录字段关联
                    $groupjoinsql.=" left join $summaintablename on $summaintablename.$sumtableindex
                                =$Detail_table.$sumDetail_table_index and $summaintablename.deleted=0   ";
                    $hadtable_arr[]=$summaintablename;
                    

                }

                if(in_array($Detail_table,$groupjoinsql_arr['jointable'])&&!in_array($Detail_table,$hadtable_arr))
                {
                    //分录字段关联
                    $groupjoinsql.=" left join $Detail_table on $summaintablename.$sumtableindex
                                =$Detail_table.$sumDetail_table_index    ";
                    $hadtable_arr[]=$Detail_table;
                     

                }
                $sumtablename=$sumfocus->customFieldTable[0];
                if(in_array($sumfocus->customFieldTable[0],$sumtable_arr)&&!in_array($sumtablename,$hadtable_arr))
                {
                    //求和字段是自定义表
                    $groupjoinsql.=" left  join $sumtablename on $sumtablename.$sumtableindex=$summaintablename.$sumtableindex   ";
                    $hadtable_arr[]=$sumtablename;

                }

                if(in_array($sumfocus->Detail_table,$sumtable_arr)&&!in_array($sumfocus->Detail_table,$hadtable_arr))
                {
                    $sumtablename = $sumfocus->Detail_table;
                    $Detail_table_index = $sumfocus->Detail_table_index;
                    //求和字段是明细表的住表
                    $groupjoinsql.=" left  join $sumtablename on $sumtablename.$Detail_table_index=$summaintablename.$sumtableindex   ";
                    $hadtable_arr[]=$sumtablename;
                }

                if(in_array($Detail_table_scf,$sumtable_arr)&&!in_array($Detail_table_scf,$hadtable_arr))
                {
                    //求和字段是明细表的自定义表

                    if( !in_array($Detail_table,$hadtable_arr)){
                       // $sumtablename = $sumfocus->Detail_table;
                        $Detail_table_index = $sumfocus->Detail_table_index;
                        $groupjoinsql.=" left  join $Detail_table on $Detail_table.$Detail_table_index=$summaintablename.$sumtableindex   ";
                        $hadtable_arr[]=$Detail_table;
                         
                    }


                    $sumtablename = $sumfocus->Detail_table_scf;
                    if( !in_array($sumtablename,$hadtable_arr)) {
                        $groupjoinsql .= " left  join $sumtablename on $sumtablename.$Detail_table_id=$Detail_table.$Detail_table_id   ";
                        $hadtable_arr[] = $sumtablename;
                    }
                }


            }
            else{
                //print_r("---".$i."---".$curmodule.$nextmodule.'---');
                //print_r($groupjoinsql_arr);
                //print_r($curfocus->table_name); 这里有问题 20231009 客户->合同->采购合同->付款单  对采购订单合计值求和 按客户分组时候有问题
                //$groupjoinsql.=' inner join '.$curfocus->table_name.' on '.$groupjoinsql_arr['bwmodulesql'];
            }

            if(in_array($curmodule,$groupmodule_arr))
            {

                if(in_array($curfocus->customFieldTable[0],$grouptable_arr)
                    &&!in_array($curfocus->customFieldTable[0],$hadtable_arr))
                {
                    //统计字段是自定义表字段
                    $groupjoinsql.=' left join '.$curfocus->customFieldTable[0].' on '.$curfocus->customFieldTable[0].'.'.
                        $curfocus->table_index.'='.$curfocus->table_name.'.'.$curfocus->table_index;
                    $hadtable_arr[]=$curfocus->customFieldTable[0];

                }
            }

        }


        if(trim($groupjoinsql)=='')
        {

            $curmodule=$allmodules[$summoduleindex];
            $curfocus=CRMEntity::getInstance($curmodule);
            $nextfocus=CRMEntity::getInstance($nextmodule);
            $groupjoinsql=$curfocus->table_name;
            $table_name=$curfocus->table_name;
            $customtable=$curfocus->customFieldTable[0];
            $table_index=$curfocus->table_index;
            $Detail_table_scf=$curfocus->Detail_table_scf;
            $Detail_table=$curfocus->Detail_table;
            $Detail_table_index=$curfocus->Detail_table_index;
            $Detail_table_id=$curfocus->Detail_table_id;
            $hadtable_arr[]=$curfocus->table_name;
            //分组的字段来自自定义表 也需要表连接
            if(in_array($curfocus->customFieldTable[0],$sumtable_arr)||in_array($curfocus->customFieldTable[0],$grouptable_arr))
            {
                $groupjoinsql.=" left join $customtable on $customtable.$table_index=$table_name.$table_index ";
                $hadtable_arr[]=$curfocus->customFieldTable[0];
            }

            if(get_file_address($curfocus->module_name,"ProductDetails"))
            {

                if(in_array($Detail_table,$sumtable_arr)&&!in_array($Detail_table,$hadtable_arr))
                {
                    $groupjoinsql.=" left join $Detail_table on $Detail_table.$Detail_table_index=$table_name.$table_index ";
                    if(in_array('ld_products',$sumtable_arr)||in_array('ld_productcf',$sumtable_arr)){
                        $groupjoinsql .= 'left join ld_products on '.$Detail_table.'.productid=ld_products.productid';
                        $hadtable_arr[]='ld_products';
                        //zxm 20230802 分组字段是产品自定义字段
                        if(in_array('ld_productcf',$sumtable_arr)){
                            $groupjoinsql .= ' left join ld_productcf on ld_productcf.productid=ld_products.productid';
                            $hadtable_arr[]='ld_productcf';
                        }
                    }
                    $hadtable_arr[]=$Detail_table;
                }

                if(in_array($Detail_table_scf,$sumtable_arr)&&!in_array($Detail_table_scf,$hadtable_arr))
                {

                    //求和字段是明细表的自定义表
                    if( !in_array($Detail_table,$hadtable_arr))
                        $groupjoinsql.=" left join $Detail_table on $Detail_table.$Detail_table_index=$table_name.$table_index ";
                    $hadtable_arr[]=$Detail_table;
                    $groupjoinsql.=" left  join $Detail_table_scf on $Detail_table_scf.$Detail_table_id=$Detail_table.$Detail_table_id   ";
                    $hadtable_arr[]=$Detail_table_scf;
                }
            }

        }

        //统计字段 主表自定义字段 zxm-2021-12-10
        foreach($this->detailviewobj->column_arr as $tmpFieldinfo)
        {
            //跨模块分组字段  排序要使用另外一个模块的字段
            $tmpFieldinfo_arr=explode(":",$tmpFieldinfo['columns']);
            $temp_table = $tmpFieldinfo_arr[0];
            $temp_field_module_arr=explode("_",$tmpFieldinfo_arr[3]);
            $temp_field_focus = CRMEntity::getInstance($temp_field_module_arr[0]);
            if(empty($tmpFieldinfo['total_type'])){
                continue;
            }
            //统计字段才走以下逻辑进行表链接
            if(in_array($temp_table,$temp_field_focus->customFieldTable)&&!in_array($temp_table,$hadtable_arr)&&in_array($temp_field_module_arr[0],$nextmodules))
            {

                //求和字段是自定义表
                if(!in_array($temp_field_focus->table_name,$hadtable_arr)){
                    $tempmoduleindex=array_search($temp_field_module_arr[0],$allmodules);

                    if(in_array($temp_field_module_arr[0],$prevmodules)&&array_search($temp_field_module_arr[0],$prevmodules)==0){
                        //zxm 20231205 如果是上游模块 表链接的方式不一样
                        $tablejoinobj= cls_TableJoin_module::getInstance($temp_field_module_arr[0],$nextmodules[0]);
                    }else{

                        if($tempmoduleindex==0)
                        {
                            //edit:can 240110-54 报表分析-项目人天汇总表2、项目人天明细表这两个报表,用外出天数进行求和，出来的数据是空的，如图。

                            continue;
                        }
                        /*$tablejoinobj= cls_TableJoin_module::getInstance($allmodules[$tempmoduleindex-1],$temp_field_module_arr[0]);

                        $cur_module = $tempmoduleindex > 0 ? $allmodules[$tempmoduleindex-1] : $allmodules[count($allmodules) - 1];
                        $tablejoinobj= cls_TableJoin_module::getInstance($cur_module,$temp_field_module_arr[0]);*/

                    }

                    $groupjoinsql_arr=$tablejoinobj->getJoin();

                    $tmpmaintablename=$temp_field_focus->table_name;
                    $tmpmaintableindex=$temp_field_focus->table_index;
                    $detail_table=$temp_field_focus->Detail_table;

                    $Detail_table_index=$temp_field_focus->Detail_table_index;

                    if(in_array($temp_field_module_arr[0],$prevmodules)&&array_search($temp_field_module_arr[0],$prevmodules)==0){
                        //zxm 20231205 如果是上游模块 表链接的方式不一样
                        $groupjoinsql.= $groupjoinsql_arr['joinsqltype']. " " . $temp_field_focus->table_name. " on " .$groupjoinsql_arr['bwmodulesql'];
                        $hadtable_arr[]=$temp_field_focus->table_name;
                    }else{
                        $groupjoinsql.= ' left  join '.$groupjoinsql_arr['joinsql'];
                        $hadtable_arr=array_merge($groupjoinsql_arr['jointable'],$hadtable_arr);
                    }

                    if(!in_array($tmpmaintablename,$groupjoinsql_arr['jointable'])
                        &&in_array($detail_table,$groupjoinsql_arr['jointable']))
                    {
                        $groupjoinsql.=" left join $tmpmaintablename    on $detail_table.$Detail_table_index=$tmpmaintablename.$tmpmaintableindex  and $tmpmaintablename.deleted=0";

                        $hadtable_arr[]=$tmpmaintablename;
                    }




                    /* if(!in_array($temp_field_focus->table_name,$hadtable_arr)){

                         $groupjoinsql.=" left  join ".$temp_field_focus->table_name." on ".$temp_field_focus->table_name.".".$temp_field_focus->table_index."=$temp_table.".$temp_field_focus->table_index;
                         $hadtable_arr[]=$temp_field_focus->table_name;
                     }*/
                }


                $groupjoinsql.=" left  join $temp_table on ".$temp_field_focus->table_name.".".$temp_field_focus->table_index."=$temp_table.".$temp_field_focus->table_index;
                $hadtable_arr[]=$temp_table;

            }

            //zxm 2022-6-9 0052267  1、报表分析-（费用报销单-合同汇总）-编辑条件-合同名称不为空点搜索无效（开发部账套也是一样）
            //2、报表分析-（费用报销单-合同汇总）-对合同名称分组，统计不出来数据（合同名称是分录中源单合同订单引用过来的，估计是因为这个）

            if($temp_table==$temp_field_focus->Detail_table&&!in_array($temp_table,$hadtable_arr)&&in_array($temp_table,$sumtable_arr))
            {
                //求和字段是明细表
                $groupjoinsql.=" left  join $temp_table on ".$temp_field_focus->table_name.".".$temp_field_focus->table_index."=$temp_table.".$temp_field_focus->Detail_table_index;
                $hadtable_arr[]=$temp_table;
            }

            if($temp_table==$temp_field_focus->Detail_table_scf&&!in_array($temp_table,$hadtable_arr)&&in_array($temp_table,$sumtable_arr))
            {

                //求和字段是明细自定义表
                if(!in_array($temp_field_focus->Detail_table,$hadtable_arr)){
                    $groupjoinsql.=" left  join $temp_field_focus->Detail_table on ".$temp_field_focus->table_name.".".$temp_field_focus->table_index."=$temp_field_focus->Detail_table.".$temp_field_focus->Detail_table_index;
                    $hadtable_arr[]=$temp_field_focus->Detail_table;
                }
                $groupjoinsql.=" left  join $temp_table on ".$temp_field_focus->Detail_table.".$temp_field_focus->Detail_table_id=$temp_table.$temp_field_focus->Detail_table_id";
                $hadtable_arr[]=$temp_table;
            }


        }
        $len=sizeof($allmodules);
        if(in_array($groupmodule_arr[$lengroupmodule-1],$prevmodules))
        {
            //如果分组字段的统计字段 是下游模块，则：

            $lastgroupbymoduleindex=-10000;
        }
        for($i=$summoduleindex;$i<$lastgroupbymoduleindex;$i++)
        {
            if($i+1>=$len)
            {
                break;
            }
            else{

            }
            $curmodule=$allmodules[$i];
            $curfocus=CRMEntity::getInstance($curmodule);
            $nextmodule=$allmodules[$i+1];
            if(in_array($nextmodule,$prevmodules)){
                continue;
            }
            $nextfocus=CRMEntity::getInstance($nextmodule);

            $tablejoinobj= cls_TableJoin_module::getInstance($curmodule,$nextmodule);
            $groupjoinsql_arr=$tablejoinobj->getJoin();

            $curmoduleindex=array_search($curmodule,$allmodules);

            $hadtable_arr[]=$curfocus->table_name;


            if($i==$summoduleindex)
            {

                if(!in_array($groupjoinsql_arr['jointable'][0],$hadtable_arr))
                {
                    $groupjoinsql.=' left join '.$groupjoinsql_arr['joinsql'];
                    $hadtable_arr[]=$groupjoinsql_arr['jointable'][0];
                }


                $summaintablename=$sumfocus->table_name;
                $sumtableindex=$sumfocus->table_index;
                $sumDetail_table_index=$sumfocus->Detail_table_index;
                $Detail_table=$sumfocus->Detail_table;
                $Detail_table_id=$sumfocus->Detail_table_id;

                if(in_array($sumfocus->Detail_table,$groupjoinsql_arr['jointable'])&&!in_array($summaintablename,$hadtable_arr))
                {
                    //分录字段关联

                    $groupjoinsql.=" left join $summaintablename on $summaintablename.$sumtableindex=$Detail_table.$sumDetail_table_index and $summaintablename.deleted=0   ";
                    $hadtable_arr[]=$summaintablename;
                }
                if(in_array($sumfocus->customFieldTable[0],$sumtable_arr)&&!in_array($sumfocus->customFieldTable[0],$hadtable_arr))
                {
                    //求和字段是自定义表

                    $sumtablename=$sumfocus->customFieldTable[0];
                    $groupjoinsql.=" left  join $sumtablename on $sumtablename.$sumtableindex=$summaintablename.$sumtableindex   ";
                    $hadtable_arr[]=$sumtablename;
                }
                if(in_array($Detail_table,$sumtable_arr)&&!in_array($Detail_table,$hadtable_arr))
                {
                    //求和字段是自定义表

                    $groupjoinsql.=" left  join $sumtablename on $sumtablename.$sumtableindex=$summaintablename.$sumtableindex   ";
                    $hadtable_arr[]=$sumtablename;
                }
                if(in_array($Detail_table_scf,$sumtable_arr)&&!in_array($Detail_table_scf,$hadtable_arr))
                {
                    //求和字段是明细表的自定义表
                    if( !in_array($Detail_table,$hadtable_arr))
                        $groupjoinsql.=" left  join $sumtablename on $sumtablename.$sumtableindex=$summaintablename.$sumtableindex   ";
                    $hadtable_arr[]=$Detail_table;
                    $groupjoinsql.=" left  join $sumtablename on $sumtablename.$Detail_table_id=$Detail_table.$Detail_table_id   ";
                    $hadtable_arr[]=$sumtablename;

                }

            }
            else{

                $hadtable_arr=array_merge($groupjoinsql_arr['jointable'],$hadtable_arr);
                //$groupjoinsql.=$curfocus->table_name.$groupjoinsql_arr['joinsqltype'].' on '.$groupjoinsql_arr['bwmodulesql'];
                $groupjoinsql.=$groupjoinsql_arr['joinsqltype'].$groupjoinsql_arr['joinsql'];

            }

            if(in_array($curmodule,$groupmodule_arr))
            {

                if(in_array($curfocus->customFieldTable[0],$grouptable_arr)
                    &&!in_array($curfocus->customFieldTable[0],$hadtable_arr))
                {
                    //统计字段是自定义表字段

                    $groupjoinsql.=' left join '.$curfocus->customFieldTable[0].' on '.$curfocus->customFieldTable[0].'.'.
                        $curfocus->table_index.'='.$curfocus->table_name.'.'.$curfocus->table_index;
                    $hadtable_arr[]=$curfocus->customFieldTable[0];
                }
            }
        }



        //$page_sql=$this->detailviewobj->getDetailCondition();//获取查询条件
        //zxm 20240709 条件SQL获取一次即可  后面直接用
        $page_sql=$this->detailviewobj->conditionSql;//获取查询条件



        $page_groupby=$sumfocus->table_name.'.'.$sumfocus->table_index;
        $addgroupbyfield='';
        foreach($allmodules as $tmpindex=>$tmpmodulename)
        {
            //按照产品 统计合同 的 产品数量，产品模块是 主模块
            if($tmpmodulename==$usedgroupcolumn_arr[0]['module'])
            {
                if($tmpindex<sizeof($allmodules))
                {
                    if($allmodules[$tmpindex+1]==$sumfocus->module_name)
                    {
                        global  $adb;
                        $sql='select * from ld_relatedlists where tabid=? and  related_tabid=? ';
                        $tmpresult=$adb->pquery($sql,array(getTabid($tmpmodulename),getTabid($sumfocus->module_name)));
                        $related_coltable=$adb->query_result($tmpresult,0,'related_coltable');
                        if("ld_".$related_coltable==$sumfocus->Detail_table.'.productid')
                        {
                            //先简单吧，就用 productid//zxm 20231020 增加产品明细主键id
                            $addgroupbyfield.=",".$sumfocus->Detail_table.".".$sumfocus->Detail_table_id.", ld_products.productid ";
                            //zxm 20231020 增加产品明细主键id
                            $joinOn_special = $sumfocus->Detail_table.".lineitem_id"."=conditionSql.".$sumfocus->Detail_table.$this->detailviewobj->asfixedname.$sumfocus->Detail_table_id;
                        }
                    }

                }
                break;
            }
        }

        /**zxm 20240528 不需要再跟条件的模块连了  条件涉及的表在条件SQL中连过了
         foreach($this->detailviewobj->wheremodule_arr as $tmpwheremodule)
        {
            if(empty($tmpwheremodule))
            {
                continue;
            }
            $tmpwherefocus=CRMEntity::getInstance($tmpwheremodule);
            $tablename=$tmpwherefocus->table_name;
            $tableindex=$tmpwherefocus->table_index;
            if(!in_array($tablename,$hadtable_arr))
            {
                foreach($allmodules as $index=>$tmpmodule)
                {
                    if($tmpwheremodule==$tmpmodule&&$tmpmodule!=$this->detailviewobj->mainmodule)
                    {
                        $beforemodule=$allmodules[$index-1];
                        $tmpbeforefocus=CRMEntity::getInstance($beforemodule);
                        $beforetablename=$tmpbeforefocus->table_name;
                        $beforetableindex=$tmpbeforefocus->table_index;

                        if(!in_array($beforetablename,$hadtable_arr))
                        {
                            //简单点吧
                            $before_beforemodule=$allmodules[$index-2];
//                            $before_beforefocus=CRMEntity::getInstance($before_beforemodule);
//                            $before_beforetablename=$before_beforefocus->table_name;
//                            $before_beforetableindex=$before_beforefocus->table_index;
                            $relatetablejoinobj = cls_TableJoin_module::getInstance($before_beforemodule, $beforemodule);
                            $tmpjoin_arr=$relatetablejoinobj->getJoin();
                            $groupjoinsql.=' left join '.$beforetablename.' on '.$tmpjoin_arr['bwmodulesql'];
                            $relatetablejoinobj = cls_TableJoin_module::getInstance($beforemodule, $tmpwheremodule);
                            $tmpjoin_arr = $relatetablejoinobj->getJoin();
                            $groupjoinsql.=' left join '.$tablename.' on '.$tmpjoin_arr['bwmodulesql'];

                        }
                        else{
                            $relatetablejoinobj = cls_TableJoin_module::getInstance($beforemodule, $tmpwheremodule);
                            $tmpjoin_arr = $relatetablejoinobj->getJoin();
                            $groupjoinsql.=' left join '.$tablename.' on '.$tmpjoin_arr['bwmodulesql'];
                        }
                        break;
                    }
                }
            }
        }**/
        $in_groupby_field_arr = [];

        //zxm 20221012 查询条件是明细表的字段--且求和的也是明细表的
        $joinOn = "$page_groupby=conditionSql.".$sumfocus->table_name.$this->detailviewobj->asfixedname.$sumfocus->table_index;
        $DetailDableIdFieldGroup = '';

        if(!empty($this->detailviewobj->DetailDableIdField)&&!empty($this->detailviewobj->DetailDableIdField[0])
        &&in_array($sumfocus->Detail_table,$hadtable_arr)
        ){
            //如果条件包含明细表的条件
            $DetailDableIdFieldGroup= ','.$this->detailviewobj->DetailDableIdField[0];
            $DetailDableIdFieldArr = explode('.',$this->detailviewobj->DetailDableIdField[0]);
            $joinOn = $this->detailviewobj->DetailDableIdField[0].'=conditionSql.'.$sumfocus->Detail_table. $this->detailviewobj->asfixedname.$DetailDableIdFieldArr[1];
        }

        //zxm 20231020 增加产品明细主键id
        if(!empty($joinOn_special)){
            $joinOn = $joinOn_special;
        }


        //zxm 20231009 条件sql不为空才inner join 条件子查询

        if(!empty($page_sql))
            $groupjoinsql.=" inner join  ($page_sql group by $page_groupby $addgroupbyfield $DetailDableIdFieldGroup) as conditionSql on ".$joinOn;
        /*foreach($this->detailviewobj->wheremodule_arr as $tmpwheremodule)
        {
            $tmpwherefocus=CRMEntity::getInstance($tmpwheremodule);
            $tablename=$tmpwherefocus->table_name;
            $tableindex=$tmpwherefocus->table_index;
            if($tablename!=$sumfocus->table_name)
            {
                $groupjoinsql.=" and  conditionSql.$tableindex=$tablename.$tableindex ";
            }

        }*/

        //再连一下分组字段所在的表$usedgroupcolumn_arr[]=['module'=>$groupmodule,'tablename'=>$groupcolumn_arr[0],'column'=>$groupcolumn_arr[1]];
        if(!in_array($conditionsql2table,$hadtable_arr))
            $groupjoinsql .= $endrightjionsql;
        //最后再连一下条件SQL
        if(!empty($endrightjionsql))
             $groupjoinsql.= " inner join  ($page_sql group by $conditionsql2ongroupby) as conditionSql2  on ".$conditionsql2on;

        return $groupjoinsql;

    }
}

?>