//
//  OCREngine.h
//  OCREngine
//
//  Created by Wolf on 1/23/16.
//  Copyright (c) 2016 Wolf. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma once
#include "NipTypes.h"

void*	Engine_Create();

void	Engine_Recognition(void* hEngineHandle, NipByte *pbyGray, int width, int height, NipRect *pRtROI, int nCntROI, ROIINFO_DATA *pResult, int nUnit);

void	Engine_Destroy(void* hEngineHandle);
