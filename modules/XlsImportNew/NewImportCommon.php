<?php

class NewImportCommon
{
    
    public static function operationDateTime($str)
    {
         if($str ==''){
             $str=NULL;
         }else{
                if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2){
                if(sizeof(explode('.',$str))==3)
                {
                    $datastrs=explode('.',$str);
                    if(strlen($datastrs[0])<4)
                    {
                    $datastrs[0]="20".$datastrs[0];
                    }
                    $str=$datastrs[0].'-'.$datastrs[1].'-'.$datastrs[2];
                                                        
                }
                else
                    $str= date('Y-m-d H:i:s',(PHPExcel_Shared_Date::ExcelToPHP($str)));  
                }
                else if(sizeof(explode('/',$str))==3)
                {
                    $datastrs=explode('/',$str);
                    if(strlen($datastrs[2])==4)
                    {
                     $str=$datastrs[2].'-'.$datastrs[1].'-'.$datastrs[0];
                                                    
                    }
                }             
         }
         return $str;
    }
    
    public static function operationDate($str)
    {
        if($str==''){
            $str=NULL;
        }else{
            if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2)
            {
                if(sizeof(explode('.',$str))==3)
                {
                    $datastrs=explode('.',$str);
                    if(strlen($datastrs[0])<4)
                    {
                    $datastrs[0]="20".$datastrs[0];
                    }
                    $str=$datastrs[0].'-'.$datastrs[1].'-'.$datastrs[2];
                                                                            
                }
                else
                $str= date('Y-m-d',(PHPExcel_Shared_Date::ExcelToPHP($str)));  
            }
            else if(sizeof(explode('/',$str))==3)
            {
                $datastrs=explode('/',$str);
                if(strlen($datastrs[2])==4)
                {
                $str=$datastrs[2].'-'.$datastrs[1].'-'.$datastrs[0];
                                                                        
                }
            }              
        }
        return $str;
    }
    
}

?>