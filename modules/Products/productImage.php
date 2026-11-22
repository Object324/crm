<?php
$productid=$_REQUEST['id'];
$rowid=$_REQUEST['rowid'];
$columnname = (!empty($_REQUEST['columnname']) && $_REQUEST['columnname'] != 'undefined' )?$_REQUEST['columnname']:'imagename';
$image_lists['total_images']=0;
if(empty($productid))
{
    $image_lists['total_images']=0;
    ob_flush();
    ob_clean();
    echo json_encode($image_lists) ;
    exit();
}
 $image_lists['product_rowid']=$rowid;
//ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示(分录选产品)
 $image_lists['columnname']=$columnname;
$images = array();
         $query = 'select productname,ld_attachments.newfile_name, ld_attachments.path,
             ld_attachments.attachmentsid, ld_attachments.name,ld_crmentity.setype,ld_attachments.storage_location
             ,ld_attachments.cloud_path 
             from ld_products left join ld_seattachmentsrel
              on ld_seattachmentsrel.crmid=ld_products.productid
               inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid 
               inner join ld_crmentity on ld_crmentity.crmid = ld_attachments.attachmentsid 
               where ld_crmentity.setype="Products Image" and ld_seattachmentsrel.attachmentcolumnname=? and productid=?';
         $result_image = $adb->pquery($query, array($columnname, $productid));
  		for ($image_iter = 0; $image_iter < $adb->num_rows($result_image); $image_iter++)
         {
            				$image_id_array[] = $adb->query_result($result_image, $image_iter, 'attachmentsid');
            				$image_array[] = (decode_html($adb->query_result($result_image, $image_iter, 'newfile_name')));
            				$image_orgname_array[] = decode_html($adb->query_result($result_image, $image_iter, 'name'));
                            $image_newfile_array[] = decode_html($adb->query_result($result_image, $image_iter, 'newfile_name'));
            				$imagepath_array[] = $adb->query_result($result_image, $image_iter, 'path');
                            $imagestorage_location[]=$adb->query_result($result_image, $image_iter, 'storage_location');
                            $imagecloud_path[]=$adb->query_result($result_image, $image_iter, 'cloud_path');
       		}
                       
 			if (count($image_array) > 1) 
             {
            				if (count($image_array) < 4)
            					$sides = count($image_array) * 2;
            				else
            					$sides=8;
                               
                                $image_lists['product_Car_NoOfSides']=$sides;
                                
            		
            				for ($image_iter = 0; $image_iter < count($image_array); $image_iter++) 
                            {
                                if($imagestorage_location[$image_iter]=='cos')
                                {
                                    $images[]=$imagecloud_path[$image_iter].','.$imagecloud_path[$image_iter];
                                }
            				    else{
            				         $imagepath=$imagepath_array[$image_iter] . $image_id_array[$image_iter] . "_" . $image_array[$image_iter];
                                
                                     if(!file_exists($imagepath))
                                     {
                                         $lastimg=explode('.',$image_array[$image_iter]);
                                         $lastimg=$lastimg[sizeof($lastimg)-1];
                                         $imagepath=$imagepath_array[$image_iter] . $image_id_array[$image_iter] . "_1.".$lastimg;
                                        
                                         if(!file_exists($imagepath))
                                        {
                                            
                                                    $imagepath=$imagepath_array[$image_iter] . $image_array[$image_iter];
                                                
                                               
                                                    
                                           
                                        }
                                     }
                                     $images[] =  $imagepath . ',' . $imagepath ;
            				    }
                                
                                
            					
                                 
            				}
                            
                            $image_lists['total_images']=sizeof($images);
            				$image_lists['images']=$images;
                            
 			} elseif (count($image_array) == 1) 
             {
						 if($imagestorage_location[0]=='cos')
                         {
                            $imagepath=$imagecloud_path[0];
                         }
                         else
                         {
                            $image_array[0] = urlencode(decode_html( $image_array[0]));
                			 $imagepath= $imagepath_array[0] . $image_id_array[0] . "_" . $image_array[0];
                              
                             if(!file_exists($imagepath))
                             {
                                $lastimg=explode('.',$image_array[0]);
                                $imagepath= $imagepath_array[0] . $image_id_array[0] . "_1.".$lastimg[sizeof($lastimg)-1];
                                if(!file_exists($imagepath))
                                {
                                   
                                     if (strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
                                        {
                                             $imagepath = $imagepath_array[0] . $image_array[0];
                                             
                                        }
                                        else
                                        {
                                            $imagepath = $imagepath_array[0] . iconv('utf-8', 'GBK', $image_array[0]);
                                            
                                            
                                        }
                                    
                                }
                             }
                         }
                         
						 list($pro_image_width, $pro_image_height) = getimagesize($imagepath);
                         $deployarray=getSys_deploy(75);
						 $val = explode(',',$deployarray['deploy_value']);
						 if($pro_image_width > 0 && $pro_image_width <= $val[0] && $pro_image_height > 0 && $pro_image_height <= $val[1]){
							$column_value= '<img src="' . $imagepath . '" onclick="previewImage(this)" border="0" width="' . $pro_image_width . '" height="' . $pro_image_height . '">';
						 }else{
							$column_value= '<img src="' . $imagepath . '" onclick="previewImage(this)" border="0" width="' . $val[0] . '" height="' . $val[1] . '">';
						 }
                    $images[]=$column_value;
                    
                    $image_lists['images']=$images;
                    $image_lists['total_images']=sizeof($images);
                   
 			}
             else 
             {
 			    
                      
     			    $image_lists['total_images']=0;
                    
 			}
            
                
            
           
            ob_flush();
            ob_clean();
            echo json_encode($image_lists) ;
            exit();

?>