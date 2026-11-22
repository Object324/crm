<?php
session_start();
require_once("config.inc.php");
//生成验证码图片
if(isset($_POST['code'])&&$_POST['code']=='2')
{
   echo 'test';
    if(md5($_POST['textvalue'])==$_SESSION[md5('codenum')])
    {
        echo '$$SUCCESS$$';
        //unset($_SESSION[md5('codenum')]);
    }
    else
    {
        echo '$$ERROR$$';
    }
    exit();
}
$width = "70";//图片宽
$height = "25";//图片高
$len = "4";//生成几位验证码
//$bgcolor = "#98CDE8";//背景色
$noise = true;//生成杂点
$noisenum = 200;//杂点数量
$border = false;//边框
$bordercolor = "#ffffff";
$image = imageCreate($width, $height);
//$back = getcolor($bgcolor);
$alpha=imagecolorallocatealpha($image,255,255,255,125);
imageFilledRectangle($image, 0, 0, $width, $height, $alpha);//填充画布
$size = $width/$len;
if($size>$height) $size=$height;
$left = ($width-$len*($size+$size/10))/$size;
/*$str='0123456789';
for($i<0;$i<4;$i++){
    $start = rand(1,strlen($str) - 1);
    $randnum .= substr($str,$start,1).','; 
}
$randnum=substr($randnum,0,strlen($randnum)-1);*/
$arr=range(0,9);
shuffle($arr);
for($i=0;$i<4;$i++)
{
    $randtext[$i]=$arr[$i];
}

$_SESSION[md5('codenum')] = md5(implode('',$randtext));  

for ($i=0; $i<4; $i++)
{	 
	
	$textColor = imageColorAllocate($image, 255, 255, 255);
	$font = $root_directory.'Image/Canvas/Fonts/1.ttf'; 
	$randsize = 20;
	$location = $left+($i*$size+$size/10);
	imagettftext($image, $randsize, rand(-18,18), $location, rand($size-$size/10, $size+$size/10), $textColor, $font, $randtext[$i]);//在图片上写文字 
}
/**
 * edit:kevin
 * date:2013-06-03
 * reason:生成杂点
 */
function setnoise()
{
	global $image, $width, $height, $back, $noisenum;
	for ($i=0; $i<$noisenum; $i++){
		$randColor = imageColorAllocate($image,212, 208, 200);  
		imageSetPixel($image, rand(0, $width), rand(0, $height), $randColor);
	} 
}
if($noise == true) setnoise();
/**
 * edit:kevin
 * date:2013-06-03
 * reason:生成图像颜色
 */ 
function getcolor($color)
{
     global $image;
     $color = str_replace ("^#","",$color);
     $r = $color[0].$color[1];
     $r = hexdec ($r);
     $b = $color[2].$color[3];
     $b = hexdec ($b);
     $g = $color[4].$color[5];
     $g = hexdec ($g);
     $color = imagecolorallocate ($image, $r, $b, $g); 
     return $color;
}
$bordercolor = getcolor($bordercolor); 
if($border==true) imageRectangle($image, 0, 0, $width-1, $height-1, $bordercolor);
header("Content-type: image/png");
@ob_clean();
imagePng($image);//建立图形
imagedestroy($image);//


?> 