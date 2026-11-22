<?php

class cls_uploads{
	
	private $filename;
	private $filepath;
	private $fileid;
    private $Aurt_dir;
    private $enCodeArr;
    private $jodconverter;


	public function __construct($filename,$filepath,$fileid){
		$this->filename = $filename;
		if(substr($filepath,-1,1)!="/"){
            $filepath.="/";
        }
		$this->filepath = $filepath;
		$this->fileid = $fileid;
		$this->jodconverter = 'jodconverter/lib/jodconverter-cli-2.2.2.jar';
        $root_directory=str_replace("\\", '/', globalStatic::$root_directory);
		$this->Aurt_dir = $root_directory . 'dataCache/AttachmentPdf/';//PDF\HTML生成目录
		$this->enCodeArr=array("EUC-CN","ASCII","UTF-8","GB2312","GBK",'BIG-5');
	}
	//office文件转换
	public function ConvertOffice(){
		set_time_limit(0);
		if(strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix'){
			return $this->ConverterToPdf();
		}else if(strtolower(PHP_OS) == "winnt"){
			return $this->OpenofficeToPdf();
		}
	}

	//window office文件转换
	private function OpenofficeToPdf(){
		$comStatus = $this->testCom('com.sun.star.ServiceManager');
		$code = -1;
		if($comStatus == false){
			$error = getFixedLabel('PLEASEINSTALLOPENOFFICE');//请安装openoffice组件
		}else{
			$root_directory=str_replace("\\", '/', globalStatic::$root_directory);
			//$output_dir = $root_directory . 'dataCache/AttachmentPdf/';//PDF生成目录
			$target_file = $root_directory . $this->filepath . $this->filename;//附件存储目录
			$pathinfo = pathinfo($target_file);
			$pdf_file = $pathinfo['filename'] . '_' . $this->fileid . ".pdf";		//pdf命名规则：文件名+附件id
			$output_file = $this->Aurt_dir . $pdf_file;
			$encode=mb_detect_encoding($target_file, $this->enCodeArr);
			if($encode=='UTF-8'){
				$target_file=iconv('UTF-8','gbk',$target_file);
			}
			$encode=mb_detect_encoding($output_file, $this->enCodeArr); 
			if($encode=='UTF-8'){
				$output_file=iconv('UTF-8','gbk',$output_file);
			}
            @chmod($output_file,0777);
			//如果pdf不存在的话，在生成
			if(!file_exists($output_file)){
				$target_file = "file:///" . $target_file;   
				$output_file = "file:///" . $output_file;
				$this->OpenOffice2Pdf($target_file,$output_file);
			}
			$code = 1;
		}
		$data = array(
			'code' => $code,
			'pdfname' => $pdf_file,//转换文件名称
			'filepath' => 'dataCache/AttachmentPdf/',	//PDF路径访问路径
			'error' => $error
		);
		return $data;
	}

	private function MakePropertyValue($name,$value,$osm){   

		$oStruct = $osm->Bridge_GetStruct("com.sun.star.beans.PropertyValue");      
		$oStruct->Name = $name;    
		$oStruct->Value = $value;    
		return $oStruct;   
	}  
	
	private function OpenOffice2Pdf($doc_url, $output_url){    
		$osm = new COM("com.sun.star.ServiceManager") or die("Unable to instantiate Word");
		$args = array($this->MakePropertyValue("Hidden",true,$osm));      
		$oDesktop = $osm->createInstance("com.sun.star.frame.Desktop");   
		$oWriterDoc = $oDesktop->loadComponentFromURL($doc_url,"_blank", 0, $args);       
		$export_args = array($this->MakePropertyValue("FilterName","writer_pdf_Export",$osm));      
		$oWriterDoc->storeToURL($output_url,$export_args);    
		$oWriterDoc->close(true);   
	} 

	private function testCom($name) {
		try {
		  $word = new COM($name); 
		  return true;
		} catch(Exception $e) {
		  return false;
		}
	}
	//linux office 转pdf、html
	private function ConverterToPdf(){
		global $default_charset;
		$code = -1;
		$error = '';
        $root_directory=str_replace("\\", '/', globalStatic::$root_directory);
		if(file_exists($root_directory .$this->jodconverter)){
			//判断java环境是否安装
			$java_info = shell_exec("java -version 2>&1");
			if(strpos($java_info, 'command not found') == false){
				//jodconverter路径
				$jodconverter_dir = $root_directory . $this->jodconverter;
				//转换附件名称
				if(substr(strrchr($this->filename, '.'), 1) == 'doc' || substr(strrchr($this->filename, '.'), 1) == 'docx'){
					$trans_filename = substr($this->filename, 0, -(strlen(substr(strrchr($this->filename, '.'), 1)) + 1)) .'_'.$this->fileid. ".pdf";
				}else{
					$trans_filename = substr($this->filename, 0, -(strlen(substr(strrchr($this->filename, '.'), 1)) + 1)) .'_'.$this->fileid. ".html";
				}
				//附件存储路径
				$target_file = $root_directory . $this->filepath . '"' . html_entity_decode($this->filename, ENT_QUOTES, $default_charset) . '"';	
				//转换附件存储路径
				$trans_file =$this->Aurt_dir . '"'.html_entity_decode($trans_filename, ENT_QUOTES, $default_charset).'"';
				$code = 1;
				if(!file_exists($this->Aurt_dir . html_entity_decode($trans_filename, ENT_QUOTES, $default_charset))){
					$shell_result = shell_exec("export LANG=en_US.UTF-8;java -jar ".$jodconverter_dir." ".$target_file." ".$trans_file." && echo 'suc'");
					if(trim($shell_result) != 'suc'){
						$code = -1;
						$error = 'office文件转换失败';
					}
				}
				if($code == 1){
					$trans_filename = str_replace("%","%25",$trans_filename);
					$trans_filename = str_replace("#","%23",$trans_filename);
				}
			}else{
				$error = '请安装jodConverter环境！';
			}
		}else{
			$error = 'jodConverter目录不存在！';
		}
		$data = array(
			'code' => $code,
			'pdfname' => $trans_filename,//转换文件名称
			'filepath' => 'dataCache/AttachmentPdf/',	//PDF路径访问路径
			'error' => $error
		);
		return $data;
	}
	/**
     * 用于外部调用,判断是否安装了openoffice
     */
	public function isInstalledOpenOffice ($name) {
		if(strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix'){
			$root_directory=str_replace("\\", '/', globalStatic::$root_directory);
			if(file_exists($root_directory .$this->jodconverter)){
				return true;
			}
			return false;
		}
		else if(strtolower(PHP_OS) == "winnt"){
			return $this->testCom($name);
		}
	}
}
?>