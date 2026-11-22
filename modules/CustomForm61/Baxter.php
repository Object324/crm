<?php
//20230410 百特送货上门模块数据导入到中间表
require_once(globalStatic::$root_directory . 'Smarty_setup.php');
global $adb,$current_user,$currentModule;
set_time_limit(0);

$_REQUEST['diony'] = 'yes';
$smarty = new lingdangCRM_Smarty();
$mode = $_REQUEST['mode'];
$operationtype = $_REQUEST['operationtype'];

if ($mode == 'import') {

    if(is_array($_FILES))
    {
        $key= key($_FILES);

        $original_name=$_FILES[$key]["name"];
        $filepath = $_FILES[$key]["tmp_name"];//上传的临时文件路径
        FileFileterString($original_name);
        if($_FILES[$key]['error'] != UPLOAD_ERR_OK || !is_uploaded_file($filepath))
        {
            ConvertTojsonString(-1,array(),"上传失败！");
        }
        else
        {
            //开始导入文件数据
            require_once(globalStatic::$root_directory."PHPExcel/PHPExcel.php");
//            require_once(globalStatic::$root_directory."PHPExcelNew/Classes/PHPExcel.php");

            $filetype = strtolower(pathinfo($original_name, PATHINFO_EXTENSION));//获取导入文件的后缀名

            if($filetype=='csv'){
                $inputFileType = 'CSV';
            } elseif($filetype=='xlsx'){
                $inputFileType = 'Excel2007';
            }else{
                $inputFileType = 'Excel5';
            }
            @ob_clean();
            // @ob_flush();
            // 创建一个PHPExcel对象
            $objPHPExcel = new PHPExcel();


            if ($inputFileType == 'CSV') {
                //检测上传的文件编码
                $file_contents = file_get_contents($filepath);
                $encoding = mb_detect_encoding($file_contents, "UTF-8, GBK, GB2312, ISO-8859-1,UTF-16,Big5", true);
                if (strtolower($encoding) != 'utf-8') {
                    ConvertTojsonString(-1,array(),"上传失败！文件编码为：'".$encoding."'，请修改为UTF-8无BOM编码后再上传！");
                }

                // 加载CSV文件，注意需要设置文件编码为UTF-8
                $objReader = PHPExcel_IOFactory::createReader('CSV');
                $objReader->setDelimiter("\t"); // 设置分隔符为制表符
//                $objReader->setDelimiter(','); // windows系统会把某些两列的值合并到一起（测试是跟最后一个字有关），并用逗号隔开，有问题，网友说linux系统正常
                $objReader->setEnclosure('"');
                $objReader->setSheetIndex(0);
                $objReader->setInputEncoding('UTF-8');
                $objPHPExcel = $objReader->load($filepath);


                // 获取CSV文件中的所有行数据
                $rows = $objPHPExcel->getActiveSheet()->toArray(); // 二维数组

                if (is_array($rows) && count($rows) > 1) {
//                    $rows = array_reduce($rows, 'array_merge', array());//二维数组合并成一维数组，效率低很多，废弃
                    array_shift($rows);//删除第一行标题
                }else{
                    ConvertTojsonString(-1,array(),"上传失败,数据不符合规范！");
                }



                //导入前先清除表信息SQL
                $adb->pquery('delete from `ld_customform61_tmpimport`;',array());

                // 循环遍历所有行数据
                $insertSQL = 'insert into ld_customform61_tmpimport (jingxiaoshang,province,patient_name,extraneal,phone1,phone2,phone3,phone4,phone5,phone6,hospital,address,aikao_only,delivery_date) values ';

                $rows_chunk = array_chunk($rows, 5000);//实测1000和5000条每次导入的时间基本一样，phpexcel读取会花费很多时间。

                $chars = array("'", "\"", "\r", "\n", "\\");// 定义需要替换的字符
                $replacement = "";// 定义替换的字符

                foreach ($rows_chunk as $chunk){
                    $tmp_value = "";
                    foreach ($chunk as $row) { //将指定分割的数据块组装成一个sql去执行
                        // 获取每一行中的所有列数据 $row
                        /*Array(
                            [0] => 上药控股有限公司,上海,陈瞻杰,5L,18930896007,,,,,,复旦大学附属儿科医院,林吉路833弄1012号,2023-02-02
                        )*/
                        $tmp_data = explode(',',$row[0]);
                        $tmp_data = array_map('trim', $tmp_data);

                        $tmp_data = array_map(function($value) use ($chars, $replacement) {
                            return str_replace($chars, $replacement, $value);
                        }, $tmp_data);

//                        $tmp_data = array_map('addslashes', $tmp_data);

                        $tmp_value.='("' . implode('", "', $tmp_data) . '"),';
                    }


                    $tmp_value=rtrim($tmp_value,',');
//                file_put_contents(globalStatic::$root_directory.'aaxtertest.txt',"\r\n".$insertSQL.$tmp_value,FILE_APPEND);
                    $adb->pquery($insertSQL.$tmp_value);
//                    echo $adb->getLastInsertID()."<br>";
                }
            }
            else{
                $objReader = PHPExcel_IOFactory::createReader($inputFileType);
                $objPHPExcel = $objReader->load($filepath);//excel
                $objPHPExcel->setActiveSheetIndex(0); // 选择第一个 Sheet
                $rows = $objPHPExcel->getActiveSheet()->toArray(); // 获取当前 Sheet
//                dump($rows);
                if (is_array($rows) && count($rows) > 1) {
                    array_shift($rows);//删除第一行标题
                }else{
                    ConvertTojsonString(-1,array(),"上传失败,数据不符合规范！");
                }
//                dump($rows);
                //导入前先清除表信息SQL
                $adb->pquery('delete from `ld_customform61_tmpimport`;',array());

                //BUG20240414-01 ls 240416 增加写入字段 aikao_only
                // 循环遍历所有行数据
                $insertSQL = 'insert into ld_customform61_tmpimport (jingxiaoshang,province,patient_name,extraneal,phone1,phone2,phone3,phone4,phone5,phone6,hospital,address,aikao_only,delivery_date) values ';

                $rows_chunk = array_chunk($rows, 1000);//实测和5000条每次时间一样。

                $chars = array("'", "\"", "\r", "\n", "\\");// 定义需要替换的字符  字符串最后含有\，插入会失败
                $replacement = "";// 定义替换的字符
                foreach ($rows_chunk as $chunk){
                    $tmp_value = "";
                    foreach ($chunk as $row) { //将指定分割的数据块组装成一个sql去执行 $row 为数组
                        // 获取每一行中的所有列数据
                        //$row = array_slice($row,0,13);  //控制excel列数不应该超过insert into的个数,但是基于业务考虑,如果客户数据提供错误,就是不应该插入成功,否则后面路总的匹配业务就会出错。
                        $tmp_data = array_map('trim', $row);
                        // 格式化最后一个日期字段
//                        $tmp_data[count($tmp_data)-1] = date('Y-m-d', strtotime(end($tmp_data)." +1 day"));//excel的日期类型会-1天，需要补回来

                        $tmp_data = array_map(function($value) use ($chars, $replacement) {
                            return str_replace($chars, $replacement, $value);
                        }, $tmp_data);

//                    $tmp_data = array_map('addslashes', $tmp_data);

                        $tmp_value.='("' . implode('", "', $tmp_data) . '"),';
                    }


                    $tmp_value=rtrim($tmp_value,',');
//                file_put_contents(globalStatic::$root_directory.'aaxtertest.txt',"\r\n".$insertSQL.$tmp_value,FILE_APPEND);
//                    dump($insertSQL.$tmp_value);
                    $adb->pquery($insertSQL.$tmp_value);
//                echo $adb->getLastInsertID()."<br>";
                }
            }


            //插入导入记录
            $adb->pquery("INSERT INTO ld_customform61_matchstatus (is_needmatch,import_time) VALUES (?, ?);", array('yes',date("Y-m-d H:i:s")));



            $result_rows = $adb->query("select 1 from ld_customform61_tmpimport");
            $rows = $adb->num_rows($result_rows);

            ConvertTojsonString(1,array(),"上传成功".$rows."条！");
        }

    }
}
?>