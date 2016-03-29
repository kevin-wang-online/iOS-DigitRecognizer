# DigitRecognizer

a digit recognizer

数字识别引擎，识别的核心源码是采用C++，封装.a静态库的形式供外部调用。

使用方式：

对外接口，文件需要采取混编的模式进行定义。

//运行引擎接口

void*	Engine_Create();

//图片数字识别接口

//hEngineHandle 话柄

//pbyGray

//width 宽

//height 高

//pRtROI

//nCntROI

//pResult

//nUnit

void	Engine_Recognition(void* hEngineHandle, NipByte *pbyGray, int width, int height, NipRect *pRtROI, int nCntROI, ROIINFO_DATA *pResult, int nUnit);

//关闭引擎接口
void	Engine_Destroy(void* hEngineHandle);
