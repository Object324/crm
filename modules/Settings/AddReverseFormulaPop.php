<?php
global $current_user;
require('include/ProductToolFields/cls_AutoLoadDetailFields.php');
$smarty=new lingdangCRM_Smarty();

require_once(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$reversefieldtype=$_REQUEST['reversefieldtype'];
$reversefieldid=$_REQUEST['reversefieldid'];
$reversetable=$_REQUEST['reversetable'];
$reverseparentid=$_REQUEST['reverseparentid'];
$module=$_REQUEST['frommodule'];
$tabid=getTabid($module);
$autoLoadInstance = new INSTANCE();
$producttoolobj = $autoLoadInstance->autoLoad($tabid,'Field');


global $adb;
//获取数字，金额类型字段
/*$query="select columnname,ld_tranlabel.fieldlabel from ld_producttoolfield
       	LEFT JOIN ld_tranlabel on ld_tranlabel.relateid = ld_producttoolfield.producttoolfieldid and ld_tranlabel.tabid = ld_producttoolfield.tabid  
    	 where ld_producttoolfield.tabid = ? and ld_tranlabel.languagetype=? and  ld_tranlabel.trantable = ? and ld_producttoolfield.producttoolfieldid != ? and ld_producttoolfield.uitype not in (33,37,35,36)  and presence in(0,2) and typeofdata like 'n%' GROUP BY ld_producttoolfield.producttoolfieldid
    	 order by ld_producttoolfield.sequence asc";
$formularesult=$adb->pquery($query,array($tabid,$languageType,'ld_producttoolfield',$reversefieldid));
 */
            
 $formulcolumnlistinfo=$producttoolobj->getFieldFormulaList($tabid)    ; //获取可以参与反算的字段     
$tmpsql='select ld_producttoolfield.producttoolfieldid,ld_producttoolfield.columnname,ld_reverseformula.columnstring,
                ld_reverseformula.formulastring,ld_reverseformula.reversefieldtype,ld_tranlabel.fieldlabel from ld_reverseformula
                    inner join ld_producttoolfield 
                        on ld_producttoolfield.producttoolfieldid=ld_reverseformula.relateid
                        inner join ld_tranlabel  on ld_tranlabel.relateid=ld_reverseformula.relateid
                 where ld_reverseformula.relateid=? and ld_reverseformula.reversetabid=? and reversetable=? and ld_reverseformula.parentid=? 
                 and ld_tranlabel.trantable=? and ld_tranlabel.tabid=? and ld_tranlabel.languagetype=?
                 order by ld_reverseformula.id asc ';

 $tmpresult=$adb->pquery($tmpsql,array($reversefieldid,$tabid,$reversetable,$reverseparentid,$reversetable,$tabid,$languageType));
 $tmprows=$adb->num_rows($tmpresult);
 $reverse_arr=array();
 if($tmprows>0)
 {
        //编辑反算公式
        $formulastring=$adb->query_result($tmpresult,$tmpi,'formulastring');
       
        
        $columnstring=$adb->query_result($tmpresult,$tmpi,'columnstring');
        
        
        $columnstringlabel=$columnstring;
        $producttoolfieldid=$adb->query_result($tmpresult,$tmpi,'producttoolfieldid');
        //$columnname=$adb->query_result($tmpresult,$tmpi,'columnname');
        $reversefieldlabel=$adb->query_result($tmpresult,$tmpi,'fieldlabel');
        $tmpcolumnstring= str_replace("&#039;",'"',$columnstring);
        $tmpcolumnstring=str_replace("formulavar",'"formulavar"',$tmpcolumnstring);
        $arr_columnstring=json_decode($tmpcolumnstring,true);
      
        foreach($arr_columnstring['formulavar'] as $index=>$formulainfo)
        {
                $lettervar=$formulainfo['lettervar'];
                $formulacolumn=$formulainfo['column'];
                $formulafieldlabel=$producttoolobj->getFieldInfoBykeyValue("columnname",$formulacolumn,"fieldlabel");
                $columnstringlabel=str_replace($lettervar,$formulafieldlabel,$columnstringlabel);
                $formulacolumns[]=$formulacolumn;
                $formulaletters[]=$lettervar;
        }
   
        $idindex=0;
        $objfields=array();//可以设置字段公式的字段
    //循环字段公式，显示界面
         foreach($formulacolumns as $columnname)
         {
           
            $formulahtml.=" <tr name='formual_row_$idindex' deleted='no'> ";
            $formulahtml.=" <td> ";
            $formulahtml.=" <select  name='formualcombox_$idindex'>";
            $formulahtml.=" <option value='none'></option> ";
            
            for($k=0;$k<sizeof($formulcolumnlistinfo);$k++)
            {
               $tmpfieldinfo=$formulcolumnlistinfo[$k];
               if($tmpfieldinfo->getProductToolFieldid()==$reversefieldid)
               {
                    continue;
               }
                $productcolumn=$tmpfieldinfo->getColumnName();
                $fieldlabel=$tmpfieldinfo->getFieldLabel();
                $objfields[$productcolumn]=array('columnname'=>$productcolumn,'fieldlabel'=>$fieldlabel);
				 
                if($productcolumn==$columnname)
                {
                   $formulahtml.= " <option value='".$productcolumn."' selected>".$fieldlabel."</option> ";
                }
                else
                {
                    $formulahtml.= " <option value='".$productcolumn."'>".$fieldlabel."</option> ";
                }
                
            }
            $formulahtml.='</select>';
            $formulahtml.=" </td> ";
            
            $formulahtml.=" <td> ";
             $tmpstr=trim(trim($formulaletters[$idindex],'&#039;'),',');//&#039;:是单引号的html
            $formulahtml.="<input type='text' name='formualtext_$idindex' id='formualtext_$idindex' value='".$tmpstr."' readonly=true>";
            $formulahtml.=" </td> ";
            
            $formulahtml.=" <td> ";
            $formulahtml.='<a  href="javascript:;" name="formualdeleteimg_'.$idindex.'" onclick="deleteFormulaRow(\''.$idindex.'\')"></a>';
            $formulahtml.=" </td> ";
            $formulahtml.="</tr>";
           $idindex++;
         }
        
     $smarty->assign('FORMULAHTML',$formulahtml);
    $smarty->assign("formulastring",$formulastring);
   }
   else{
         
            for($k=0;$k<sizeof($formulcolumnlistinfo);$k++)
            {
               $tmpfieldinfo=$formulcolumnlistinfo[$k];
               if($tmpfieldinfo->getProductToolFieldid()==$reversefieldid)
               {
                    continue;
               }
                $productcolumn=$tmpfieldinfo->getColumnName();
                $fieldlabel=$tmpfieldinfo->getFieldLabel();
                $objfields[$productcolumn]=array('columnname'=>$productcolumn,'fieldlabel'=>$fieldlabel);
				 
               
                
            }
            foreach($producttoolobj->getModuleProductToolField() as $index=>$fieldinfo)
            {
                if($fieldinfo->getProductToolFieldid()==$reversefieldid)
                {
                    $reversefieldlabel=$fieldinfo->getFieldLabel();
                    break;
                }
            }
       $idindex=0;   
       $letters=array('a','b','c','d');  
        for($i=0;$i<=1;$i++)
         {
           
            $formulahtml.=" <tr name='formual_row_$idindex' deleted='no'> ";
            $formulahtml.=" <td> ";
            $formulahtml.=" <select  name='formualcombox_$idindex'>";
            $formulahtml.=" <option value='none'></option> ";
            
            for($k=0;$k<sizeof($formulcolumnlistinfo);$k++)
            {
               $tmpfieldinfo=$formulcolumnlistinfo[$k];
               if($tmpfieldinfo->getProductToolFieldid()==$reversefieldid)
               {
                    continue;
               }
                $productcolumn=$tmpfieldinfo->getColumnName();
                $fieldlabel=$tmpfieldinfo->getFieldLabel();
                $objfields[$productcolumn]=array('columnname'=>$productcolumn,'fieldlabel'=>$fieldlabel);
				 
                if($productcolumn==$columnname)
                {
                   $formulahtml.= " <option value='".$productcolumn."' selected>".$fieldlabel."</option> ";
                }
                else
                {
                    $formulahtml.= " <option value='".$productcolumn."'>".$fieldlabel."</option> ";
                }
                
            }
            $formulahtml.='</select>';
            $formulahtml.=" </td> ";
            
            $formulahtml.=" <td> ";
            
            $formulahtml.="<input type='text' name='formualtext_$idindex' id='formualtext_$idindex' value='".$letters[$idindex]."' readonly=true>";
            $formulahtml.=" </td> ";
            
            $formulahtml.=" <td> ";
            $formulahtml.='<a  href="javascript:;" name="formualdeleteimg_'.$idindex.'" onclick="deleteFormulaRow(\''.$idindex.'\')"></a>';
            $formulahtml.=" </td> ";
            $formulahtml.="</tr>";
           $idindex++;
         }
          $smarty->assign('FORMULAHTML',$formulahtml);    
   }
    
    //$reverse_arr[]=array('reversefieldlabel'=>$fieldlabel,'reversefieldid'=>$producttoolfieldid,'formulastring'=>$formulastring,'columnstring'=>$columnstring,'columnstringlabel'=>$columnstringlabel);
 
 $_REQUEST['diony']='yes';
 $arr['content']=$smarty->fetch("AddReverseFormulaPop.tpl");
 $arr['oktext']=getFixedLabel("SAVE");
 $arr['canceltext']=getFixedLabel("CANCEL");
 $arr['reverseparentid']=$reverseparentid;
 $arr['reversefieldid']=$reversefieldid;
 $arr['module']=$module;
 $arr['title']=getFixedlabel("SettingFormula").'->'.$reversefieldlabel;
 foreach($objfields as $columnname=>$fieldinfo)
 {
    $tmparrs[]=$fieldinfo;
 }
 $arr['objfields']=$tmparrs;
 ConvertTojsonString(1,$arr,'success');
               
        
?>