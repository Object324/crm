<?php

class cls_CarouselSettings
{
    function __construct()
    {
    }

    //获取所有轮播图信息
    public function getAllCarouselinfos(){
        global $adb;
        $list = array();
        $query = "select * from ld_shop_carousels order by carouselseq";
        $result = $adb->pquery($query,array());
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $carouselid=$adb->query_result($result,$i,'carouselid');
            $linktype=$adb->query_result($result,$i,'linktype');
            $linkid=$adb->query_result($result,$i,'linkid');
            $status=$adb->query_result($result,$i,'status');
            $carouselseq=$adb->query_result($result,$i,"carouselseq");
            $uploadfile_name=$adb->query_result($result,$i,'uploadfile_name');
            $file_type=$adb->query_result($result,$i,'file_type');
            $file_path=$adb->query_result($result,$i,'file_path');
            $file_size=$adb->query_result($result,$i,'file_size');
            $newfile_name=$adb->query_result($result,$i,'newfile_name');
            $list[]=array('carouselseq'=>$carouselseq,'carouselid'=>$carouselid,'linktype'=>$linktype
                            ,'linkid'=>$linkid,'status'=>$status,'uploadfile_name'=>$uploadfile_name
                            ,'file_type'=>$file_type,'file_path'=>$file_path,'file_size'=>$file_size,'newfile_name'=>$newfile_name);
        }
        return $list;
    }
    
    //通过carouselid获取轮播图信息
    public function getCarouselinfoById($carouselid){
        global $adb;
        $list = array();
        $query = "select * from ld_shop_carousels where carouselid = ?";
        $result = $adb->pquery($query,array($carouselid));
        $rows=$adb->num_rows($result);
        if($rows>0){
            $carouselid=$adb->query_result($result,$i,'carouselid');
            $linktype=$adb->query_result($result,$i,'linktype');
            $linkid=$adb->query_result($result,$i,'linkid');
            $status=$adb->query_result($result,$i,'status');
            $carouselseq=$adb->query_result($result,$i,"carouselseq");
            $uploadfile_name=$adb->query_result($result,$i,'uploadfile_name');
            $file_type=$adb->query_result($result,$i,'file_type');
            $file_path=$adb->query_result($result,$i,'file_path');
            $file_size=$adb->query_result($result,$i,'file_size');
            $newfile_name=$adb->query_result($result,$i,'newfile_name');
            $list=array('carouselseq'=>$carouselseq,'carouselid'=>$carouselid,'linktype'=>$linktype
                            ,'linkid'=>$linkid,'status'=>$status,'uploadfile_name'=>$uploadfile_name
                            ,'file_type'=>$file_type,'file_path'=>$file_path,'file_size'=>$file_size,'newfile_name'=>$newfile_name);
        }
        return $list;
    }
    
    //通过carouselid获取轮播图链接内容，
    public function getCarousellinkinfoById($carouselid){
        global $adb;
        $query = "select linktype,linkid from ld_shop_carousels where carouselid = ?";
        $result = $adb->pquery($query,array($carouselid));
        $rows=$adb->num_rows($result);
        $linkname = '';
        if($rows>0){
            $linktype=$adb->query_result($result,$i,'linktype');
            $linkid=$adb->query_result($result,$i,'linkid');
            
            if($linktype == 'Carousel_ProductCategoryList'){
                $result = $adb->pquery("select listvalue from ld_picklist_values where id = ?",array($linkid));
                if($adb->num_rows($result)>0){
                    $linkname = $adb->query_result($result,$i,'listvalue');
                }
            }
            elseif($linktype == 'Carousel_Productdetails'){
                $result = $adb->pquery("select productname from ld_products where productid = ?",array($linkid));
                if($adb->num_rows($result)>0){
                    $linkname = $adb->query_result($result,$i,'productname');
                }
            }
        }
        return array('linktype'=>$linktype,'linkid'=>$linkid,'linkname'=>$linkname);
    }
    

}

?>