#pragma once

#ifndef _BASETYPES_H
#define _BASETYPES_H

#include <math.h>
#include <stdio.h>
#include <memory.h>
#include <stdlib.h>
#include <assert.h>

#include <opencv2/core/core.hpp>           // cv::Mat
#include <opencv2/highgui/highgui.hpp>     // cv::imread()
#include <opencv2/imgproc/imgproc.hpp>     // cv::Canny()
using namespace cv;

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

#ifndef PI
#define PI 3.141592653589793f
#endif

#define MAX_PATH          260

#define NipTrue			1
#define NipFalse		0
#define NipNull			0

#define IS_LETTER		1
#define IS_NODIGIT		2
#define IS_EMPTY		3
#define IS_ONE			4

	typedef void *				NipEngineHandle;
	typedef unsigned char		uint8;

	typedef void				NipVoid;
	typedef uint8				NipByte;
	typedef uint8*				NipPByte;
	typedef char				NipChar;
	typedef unsigned short		NipWord;
	typedef unsigned int		NipDWord;
	typedef	wchar_t				NipTChar;
	typedef int					NipBool;
	typedef int					NipInt;
	typedef int					NipLong;
	typedef unsigned int		NipUint;
	typedef float				NipFloat;
	typedef double				NipDouble;


	typedef struct NipPt2f
	{
		float x;
		float y;
	} NipPt2f;

	typedef struct tagNipSize
	{
		int cx;
		int cy;
	} NipSize;

	typedef struct tagNipPoint
	{
		int x;
		int y;

        void NipPoint() {}
		void NipPoint(int x1, int y1) {x = x1, y = y1;}
	} NipPoint;

	typedef struct tagNipRect
	{	
		int left;
		int top;
		int	right;
		int	bottom;
		void NipRect() {left = 0; top = 0; right = 0; bottom = 0;}
		void NipRect(int l, int t, int r, int b) {left = l; top = t; right = r;bottom = b;}
		void init(int l, int t, int r, int b) {left = l; top = t; right = r;bottom = b;}
		void init(tagNipRect rt){left = rt.left; top = rt.top; right = rt.right; bottom = rt.bottom;}
		int	width() { return right - left; }
		int	height() { return bottom - top; }
		NipPoint center() { NipPoint pt; pt.x = left + int(width() / 2.f + 0.5f); pt.y = top + int(height() / 2.f + 0.5f); return pt; }
		int area() { return width() * height(); }
		bool IntersectRect(tagNipRect rt1, tagNipRect rt2){
			left = max(rt1.left, rt2.left);
			top = max(rt1.top, rt2.top);
			right = min(rt1.right, rt2.right);
			bottom = min(rt1.bottom, rt2.bottom);
			if (right < left){
				left = right = top = bottom = 0;
				return false;
			}
			else if (bottom < top){
				left = right = top = bottom = 0;
				return false;
			}
			return true;
		}
		void UnionRect(tagNipRect rt1, tagNipRect rt2){
			if (rt1.left == 0 && rt1.right == 0 && rt1.top == 0 && rt1.bottom == 0)
			{
				left = rt2.left;
				right = rt2.right;
				top = rt2.top;
				bottom = rt2.bottom;
			}
			else if (rt2.left == 0 && rt2.right == 0 && rt2.top == 0 && rt2.bottom == 0)
			{
				left = rt1.left;
				right = rt1.right;
				top = rt1.top;
				bottom = rt1.bottom;
			}
			else
			{
				left = min(rt1.left, rt2.left);
				right = max(rt1.right, rt2.right);
				top = min(rt1.top, rt2.top);
				bottom = max(rt1.bottom, rt2.bottom);
			}
		}
	} NipRect;

	typedef NipRect*	LPNipRect;

	typedef struct tagDisplayROI { //  PLOVE Diction
		float 	score;		// average value
		NipRect	rt;			// variation
	} DisplayROI;

	typedef struct tagROIINFO
	{
		char	szDigit[30];
		int		nResult;
	}ROIINFO_DATA;
	
#ifdef __cplusplus
}
#endif
#endif // !_BASETYPES_H