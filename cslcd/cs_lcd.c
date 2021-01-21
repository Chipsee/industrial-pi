/*
 * Copyright (C) 2021 Xiaoqiang Liu <lxq@chipsee.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
*/

#include <linux/clk.h>
#include <linux/device.h>
#include <linux/gpio/consumer.h>
#include <linux/i2c.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/delay.h>

#include <linux/gpio/consumer.h>
#include <linux/regulator/consumer.h>

/*********************LVDS Output Config************************/
#define _1_Port_LVDS_	0x00
#define _2_Port_LVDS_	0x01
#define _DE_Mode_	0x20
#define _Sync_Mode_ 0x00            // LT8619C 的 sync mode 包含有 DE 信号
#define _8_bit_ColorDepth_	0x00
#define _6_bit_ColorDepth_	0x10
#define _C_D_Port_Swap_En	0x02    // if enable, 1 port output select port-D,2 ports output select port-D+port-C
#define _C_D_Port_Swap_Dis	0x00    // if disable,1 port output select port-C,2 ports output select port-C+port-D
#define _R_B_Color_Swap_En	0x01    // LVDS RGB data R/B Swap
#define _R_B_Color_Swap_Dis 0x00    // normal
#define _LVDS_Output_En		0x40
#define _LVDS_Output_Dis	0x00
#define _VESA_	0x00
#define _JEIDA_ 0x80
//如果有接外部参考电阻(Pin 16 - REXT, 2K 电阻)，优先使用外部参考电阻
//使用外部参考电阻的时候，Pin16 管脚上只接2K 电阻，不能接Vcc1.8以及接地电容。
//默认使用内部参考电阻
#define _Internal_	0x88
#define _External_	0x80
//设置IIS 音频输出，IIS和SPDIF只能二选一
#define _IIS_Output_ 0x11
//设置SPDIF 音频输出，IIS和SPDIF只能二选一
#define _SPDIF_Output_ 0x39
//xxPC:full range;	xxTV:limit range
#define SDTV	0x00        
#define SDPC	0x10        
#define HDTV	0x20        
#define HDPC	0x30        
#define _6bit_Dither_En		0x38
#define _6bit_Dither_Dis	0x00
/*********************LVDS Output Config************************/

typedef enum
{
	LOW    = 0,
	HIGH   = !LOW
} Pin_Status;

//下面的EDID数据会被系统启动时检测到，但是该程序目前在系统启动后才会被烧录
//所以需要系统设置分辨率，配合该程序使用
const u8 ONCHIP_EDID[256] = {
	/* 1280x800 60Hz 71MHz */
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x32, 0x8d, 0xc5, 0x07, 0x01, 0x00, 0x00, 0x00,
	0x2e, 0x14, 0x01, 0x03, 0x80, 0x00, 0x00, 0x78, 0x0a, 0xee, 0x91, 0xa3, 0x54, 0x4c, 0x99, 0x26,
	0x0f, 0x50, 0x54, 0x21, 0x08, 0x00, 0x81, 0xc0, 0x81, 0x40, 0x81, 0x80, 0x95, 0x00, 0xa9, 0xc0,
	0xa9, 0x40, 0xd1, 0xc0, 0x01, 0x01, 0xbc, 0x1b, 0x00, 0xa0, 0x50, 0x20, 0x17, 0x30, 0x30, 0x20,
	0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1a, 0x66, 0x21, 0x50, 0xb0, 0x51, 0x00, 0x1b, 0x30,
	0x40, 0x70, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x18,
	0x4b, 0x1a, 0x51, 0x17, 0x00, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x4c, 0x4f, 0x4e, 0x54, 0x49, 0x55, 0x4d, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x01, 0xe8,
	0x02, 0x03, 0x30, 0xc1, 0x49, 0x04, 0x13, 0x01, 0x02, 0x03, 0x11, 0x12, 0x10, 0x1f, 0x23, 0x09,
	0x07, 0x07, 0x83, 0x01, 0x00, 0x00, 0x02, 0x00, 0x0f, 0x03, 0x05, 0x03, 0x01, 0x72, 0x03, 0x0c,
	0x00, 0x40, 0x00, 0x80, 0x1e, 0x20, 0xd0, 0x08, 0x01, 0x40, 0x07, 0x3f, 0x40, 0x50, 0x90, 0xa0,
	0x9e, 0x20, 0x00, 0x90, 0x51, 0x20, 0x1f, 0x30, 0x48, 0x80, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x1c, 0x0e, 0x1f, 0x00, 0x80, 0x51, 0x00, 0x1e, 0x30, 0x40, 0x80, 0x37, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x1c, 0x66, 0x21, 0x56, 0xaa, 0x51, 0x00, 0x1e, 0x30, 0x46, 0x8f, 0x33, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x1e, 0x20, 0x1c, 0x56, 0x86, 0x50, 0x00, 0x20, 0x30, 0x0e, 0x38,
	0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd7
};

struct cs_lcd {
	struct i2c_client *client;
	
	struct gpio_desc *gpio_pwren;
    struct gpio_desc *gpio_rst;
	
	/* Version of the bridge chip */
	int chip_ver;
};

static int cs_lcd_i2c_read(struct cs_lcd *lcd, u8 reg)
{
	return i2c_smbus_read_byte_data(lcd->client, reg);
}

static void cs_lcd_i2c_write(struct cs_lcd *lcd,
				      u8 reg, u8 val)
{
	int ret;

	ret = i2c_smbus_write_byte_data(lcd->client, reg, val);
	if (ret)
		dev_err(&lcd->client->dev, "I2C write failed: %d\n", ret);
}

u16 get_chip_id(struct cs_lcd *lcd)
{
	u8 id[2];
	u16 icid;
	cs_lcd_i2c_write(lcd,0xFF,0x60);	//change to 0x60 bank
	id[0] = cs_lcd_i2c_read(lcd,0x00);	//read high value of ID
	id[1] = cs_lcd_i2c_read(lcd,0x01);	//read low value of ID
	icid = id[0] << 8 | id[1];
	return icid;
}

void hdmi_timing_read(struct cs_lcd *lcd)
{
	struct device *dev = &lcd->client->dev;
	
	u16 H_FrontP   = 0x0000;
	u16 H_BackP	   = 0x0000;
	u16 H_SyncWid  = 0x0000;
	u16 H_total	   = 0x0000;
	u16 V_total	   = 0x0000;
	u16 H_Active   = 0x0000;
	u16 V_Active   = 0x0000;
	u8	V_FrontP   = 0x00;
	u8	V_BackP	   = 0x00;
	u8	V_SyncWid  = 0x00;
	u32 HDMI_CLK_Cnt = 0x00000000;

	cs_lcd_i2c_write( lcd, 0xFF, 0x60 ); //register bank
	cs_lcd_i2c_write( lcd, 0x0c, 0xFB );
	mdelay( 10 );
	cs_lcd_i2c_write( lcd, 0x0c, 0xFF );// reset video check
	mdelay( 100 );

	H_FrontP   = cs_lcd_i2c_read(lcd, 0x1a ) * 0x100 + cs_lcd_i2c_read(lcd, 0x1b );
	H_SyncWid  = cs_lcd_i2c_read(lcd, 0x14 ) * 0x100 + cs_lcd_i2c_read(lcd, 0x15 );
	H_BackP	   = cs_lcd_i2c_read(lcd, 0x18 ) * 0x100 + cs_lcd_i2c_read(lcd, 0x19 );
	H_Active = cs_lcd_i2c_read(lcd, 0x22 ) * 0x100 + cs_lcd_i2c_read(lcd, 0x23 );
	H_total = cs_lcd_i2c_read(lcd, 0x1E ) * 0x100 + cs_lcd_i2c_read(lcd, 0x1F );
	V_FrontP   = cs_lcd_i2c_read(lcd, 0x17 );
	V_SyncWid  = cs_lcd_i2c_read(lcd, 0x13 );
	V_BackP	   = cs_lcd_i2c_read(lcd, 0x16 );
	V_Active = cs_lcd_i2c_read(lcd, 0x20 ) * 0x100 + cs_lcd_i2c_read(lcd, 0x21 );
	V_total = ( cs_lcd_i2c_read(lcd, 0x1C ) & 0x0F ) * 0x100 + cs_lcd_i2c_read(lcd, 0x1D );
	cs_lcd_i2c_write( lcd, 0xFF, 0x80 ); //register bank
	HDMI_CLK_Cnt  = (cs_lcd_i2c_read(lcd, 0x44 ) & 0x07) * 0x10000 + cs_lcd_i2c_read(lcd, 0x45 ) * 0x100 + cs_lcd_i2c_read(lcd, 0x46 );

	dev_info(dev,"Display Timing: ");
	dev_info(dev,"========================");
	dev_info(dev,"H_Active = %d",H_Active);
	dev_info(dev,"H_FrontP = %d",H_FrontP);
	dev_info(dev,"H_BackP = %d",H_BackP);
	dev_info(dev,"H_SyncWid = %d",H_SyncWid);
	dev_info(dev,"H_total = %d",H_total);
	dev_info(dev,"-------------------------");
	dev_info(dev,"V_Active = %d",V_Active);
	dev_info(dev,"V_FrontP = %d",V_FrontP);
	dev_info(dev,"V_BackP = %d",V_BackP);
	dev_info(dev,"V_SyncWid = %d",V_SyncWid);
	dev_info(dev,"V_total = %d",V_total);
	dev_info(dev,"-------------------------");
	dev_info(dev,"HDMI_CLK_Cnt = %d KHz",HDMI_CLK_Cnt);
	dev_info(dev,"========================");
}

void cs_lcd_chip_reset( struct cs_lcd *lcd )
{
	// add it later
}

void cs_lcd_chip_set_hpd( struct cs_lcd *lcd, int level )
{
	cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
	if( level )
	{
		cs_lcd_i2c_write( lcd, 0x06, cs_lcd_i2c_read(lcd, 0x06 ) | 0x08 );
	}else
	{
		cs_lcd_i2c_write( lcd, 0x06, cs_lcd_i2c_read(lcd, 0x06 ) & 0xf7 );
	}
}

// 8619C 的EDID 写入，可以操作256次 写0x90寄存器地址，再写1 byte EDID数据；
// 或者写一次0x90地址，连续写256 次1 byte EDID数据。
// 写EDID的时候，寄存器地址不要递增。
void cs_lcd_chip_write_edid2hdmi_shadow( struct cs_lcd *lcd )
{
	int i;
	cs_lcd_i2c_write( lcd, 0x8f, 0x00 );
	for (i=0; i<sizeof(ONCHIP_EDID); i++)
	{
		cs_lcd_i2c_write( lcd, 0x90, ONCHIP_EDID[i]);
	}
}

static int cs_lcd_chip_loadhdcpkey( struct cs_lcd *lcd )
{
	u8 flag_load_key_done = 0, loop_cnt = 0;

	cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
	cs_lcd_i2c_write( lcd, 0xb2, 0x50 );
	cs_lcd_i2c_write( lcd, 0xa3, 0x77 );
	while( loop_cnt <= 5 )//wait load hdcp key done.
	{
		loop_cnt++;
		mdelay( 50 );
		flag_load_key_done = cs_lcd_i2c_read(lcd, 0xc0 ) & 0x08;
		if( flag_load_key_done )
		{
			break;
		}
	}
	cs_lcd_i2c_write( lcd, 0xb2, 0xd0 );
	cs_lcd_i2c_write( lcd, 0xa3, 0x57 );
	if( flag_load_key_done )
	{
		return 1;
	}else
	{
		return 0;
	}
}

void cs_lcd_chip_wait_hdmi_stable(struct cs_lcd *lcd)
{
	cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
	while( ( cs_lcd_i2c_read(lcd, 0x43 ) & 0x80 ) == 0x00 )//等待RX HDMI CLK信号
	{
		mdelay( 100 );
	}
	mdelay( 100 );//200
	while( ( cs_lcd_i2c_read(lcd, 0x43 ) & 0x80 ) == 0x00 )//等待RX HDMI CLK信号
	{
		mdelay( 100 );
	}
	mdelay( 100 );//200
	while( ( cs_lcd_i2c_read(lcd, 0x13 ) & 0x01 ) == 0x00 )//等待H SYNC 稳定
	{
		mdelay( 100 );
	}
	mdelay( 100 );//200
	cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
	cs_lcd_i2c_write( lcd, 0x09, 0x7f );
	mdelay( 10 );
	cs_lcd_i2c_write( lcd, 0x09, 0xFF );// reset HDMI RX logic
	mdelay( 100 );
	//HDMI_Timing_Read(lcd);
}

static int cs_lcd_chip_init(struct cs_lcd *lcd)
{
	struct device *dev = &lcd->client->dev;
	
	u8 Temp_CSC = 0x00;
	u8 Refer_Resistance = _External_;				// _Internal_  internal resistance  _External_ external resistance(Pin 16 - REXT, 2K resistance)
	u32 Load_HDCPKey_En = 0;						// 1:外接 HDCP key; 0:不使用 HDCP Key
	u8 CP_Convert_Mode = HDPC;
	u8 Audio_Output_Mode = _IIS_Output_;			// _IIS_Output_	_SPDIF_Output_
	u32 Audio_Output_En = 1;                    	// 1 : enable Audio Output
	u8 LVDS_Port = _1_Port_LVDS_;					// _1_Port_LVDS_ _2_Port_LVDS_
	u8 LVDS_SyncMode = _Sync_Mode_;					// _Sync_Mode_ _DE_Mode_
	u8 LVDS_ColorDeepth = _8_bit_ColorDepth_;		// _8_bit_ColorDepth_ _6_bit_ColorDepth_						
	u8 LVDS_C_D_Port_Swap = _C_D_Port_Swap_Dis;		// _C_D_Port_Swap_En : 1 port output select port-D,2 ports output select port-D+port-C _C_D_Port_Swap_Dis : 1 port output select port-C,2 ports output select port-C+port-D
	u8 LVDS_R_B_Color_Swap = _R_B_Color_Swap_Dis;	// _R_B_Color_Swap_En: LVDS RGB data R/B Swap   _R_B_Color_Swap_Dis: Normal	
	u8 LVDS_Map = _VESA_;							// _VESA_ _JEIDA_	
	u8 LVDS_Output_En = _LVDS_Output_En;			// enable LVDS output
	//******************************************//
	cs_lcd_chip_reset(lcd);
	cs_lcd_chip_set_hpd(lcd, LOW);//如果HDMI是强制输出，可以不需要写EDID。
	mdelay( 10 );
	cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
	cs_lcd_i2c_write( lcd, 0x8E, 0x07 ); //Enable EDID shadow operation
	cs_lcd_chip_write_edid2hdmi_shadow(lcd);
	cs_lcd_i2c_write( lcd, 0x8E, 0x02 );
	if( Load_HDCPKey_En )
	{
		cs_lcd_chip_loadhdcpkey(lcd);
	}
	cs_lcd_chip_set_hpd(lcd, HIGH);
	cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
	cs_lcd_i2c_write( lcd, 0x2c, 0x35 );//RGD_CLK_STABLE_OPT[1:0]
	cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
	cs_lcd_i2c_write( lcd, 0x80, 0x08 ); 
	cs_lcd_i2c_write( lcd, 0x89, Refer_Resistance );
	cs_lcd_i2c_write( lcd, 0x8b, 0x90 );// Normal AFE
	cs_lcd_i2c_write( lcd, 0x06, 0xe7 );
	cs_lcd_chip_wait_hdmi_stable(lcd);
	cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
	cs_lcd_i2c_write( lcd, 0x0d, 0xfb );
	mdelay( 10 );
	cs_lcd_i2c_write( lcd, 0x0d, 0xff );
	cs_lcd_i2c_write( lcd, 0x59, LVDS_Map + LVDS_Output_En + LVDS_SyncMode + LVDS_ColorDeepth + LVDS_C_D_Port_Swap + LVDS_R_B_Color_Swap );
	if(LVDS_ColorDeepth == _8_bit_ColorDepth_)
	{
		cs_lcd_i2c_write( lcd, 0x5f, _6bit_Dither_Dis ); 
	}
	else
	{
		cs_lcd_i2c_write( lcd, 0x5f, _6bit_Dither_En); 
	}
	cs_lcd_i2c_write( lcd, 0xa0, 0x58 );
	cs_lcd_i2c_write( lcd, 0xa4, LVDS_Port|0x08 ); // 00 : CLK/1 ; 01: CLK/2
	cs_lcd_i2c_write( lcd, 0xa8, 0x00 );
	cs_lcd_i2c_write( lcd, 0xba, 0x18 );// bit2= 1 => turn off LVDS C
	cs_lcd_i2c_write( lcd, 0xc0, 0x18 );// bit2= 1 => turn off LVDS D
	cs_lcd_i2c_write( lcd, 0xb0, 0x66 );
	cs_lcd_i2c_write( lcd, 0xb1, 0x66 );
	cs_lcd_i2c_write( lcd, 0xb2, 0x66 );
	cs_lcd_i2c_write( lcd, 0xb3, 0x66 );
	cs_lcd_i2c_write( lcd, 0xb4, 0x66 );
	cs_lcd_i2c_write( lcd, 0xb5, 0x41 );// DC0 ; bit1 = 1 => DC0 PN swap
	cs_lcd_i2c_write( lcd, 0xb6, 0x41 );// DC1 ; bit1 = 1 => DC1 PN swap
	cs_lcd_i2c_write( lcd, 0xb7, 0x41 );// DC2 ; bit1 = 1 => DC2 PN swap
	cs_lcd_i2c_write( lcd, 0xb8, 0x4c );// DCC ; bit7 = 1 => DCC PN swap
	cs_lcd_i2c_write( lcd, 0xb9, 0x41 );// DC3 ; bit1 = 1 => DC3 PN swap	
	cs_lcd_i2c_write( lcd, 0xbb, 0x41 );// DD0 ; bit1 = 1 => DD0 PN swap
	cs_lcd_i2c_write( lcd, 0xbc, 0x41 );// DD1 ; bit1 = 1 => DD1 PN swap
	cs_lcd_i2c_write( lcd, 0xbd, 0x41 );// DD2 ; bit1 = 1 => DD2 PN swap
	cs_lcd_i2c_write( lcd, 0xbe, 0x4c );// DDC ; bit7 = 1 => DDC PN swap
	cs_lcd_i2c_write( lcd, 0xbf, 0x41 );// DD3 ; bit1 = 1 => DD3 PN swap
	cs_lcd_i2c_write( lcd, 0xa0, 0x18 ); // 0x18
	cs_lcd_i2c_write( lcd, 0xa1, 0xb0 );
	cs_lcd_i2c_write( lcd, 0xa2, 0x10 );
	cs_lcd_i2c_write( lcd, 0x5c, LVDS_Port );
	cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
	cs_lcd_i2c_write( lcd, 0x06, 0x7f );
	cs_lcd_i2c_write( lcd, 0x0e, 0xfe );
	cs_lcd_i2c_write( lcd, 0x0d, 0xfb );
	mdelay( 10 );
	cs_lcd_i2c_write( lcd, 0x0d, 0xff );
	cs_lcd_i2c_write( lcd, 0x06, 0xff );
	cs_lcd_i2c_write( lcd, 0x0e, 0xff ); // LVDS PLL reset

	/******Color********/
	/******Color********/
	/******Color********/
	/********************LT8619C_ColorConfig（）********************************/	
	//如果在HDMI信号还没出现的时候，就调用色彩空间转换设置函数LT8619C_ColorConfig（）就有可能会判断错误，
	//因为这个函数是根据前端HDMI信号色彩空间的状态来设置。
	//如果HDMI 是YUV420输入，那只能直接按照420送出去,LT8619C没办法做色彩转换。
	//如果HDMI的色彩空间是YUV422/YUV444，需要进行色彩空间转换。
	cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
	Temp_CSC = cs_lcd_i2c_read(lcd, 0x71 );
	if(( ( Temp_CSC & 0x60 ) == 0x20 )||( ( Temp_CSC & 0x60 ) == 0x40 ) ) // 如果HDMI的色彩空间不是RGB，需要进行色彩空间转换。
	{
		cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
		cs_lcd_i2c_write( lcd, 0x07, 0x8C );                   // YCbCr to RGB ClK enable
		if( ( Temp_CSC & 0x60 ) == 0x20 )
		{
			cs_lcd_i2c_write( lcd, 0x52, 0x01 ); // YUV422 to YUV444 enable
			dev_info(dev, "HDMI Color Space is YUV422" );
		}
		else
		{
			cs_lcd_i2c_write( lcd, 0x52, 0x00 ); // YUV444
			dev_info(dev, "HDMI Color Space is YUV444" );
		}		
		cs_lcd_i2c_write( lcd, 0x53, 0x40 + CP_Convert_Mode ); // 0x40:YUV to RGB enable;
	} else {
		cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
		cs_lcd_i2c_write( lcd, 0x07, 0x80 );
		cs_lcd_i2c_write( lcd, 0x52, 0x00 );		
		cs_lcd_i2c_write( lcd, 0x53, 0x00 ); // 0x00: ColorSpace bypass
		dev_info(dev, "HDMI Color Space is RGB" );
	}
	/********************LT8619C_ColorConfig（）********************************/	

	/******AUDIO********/
	/******AUDIO********/
	/******AUDIO********/
	/******************************AUDIO_CONFIG********************************/
	if( Audio_Output_En )
	{
		if( Audio_Output_Mode == _IIS_Output_ )
		{
			cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
			// SD0 channel selected
			// 0x16: Left justified(I2S compatible); default
			// 0x14: Right justified;
			// If the setting is not correct, there will be noise.
			cs_lcd_i2c_write( lcd, 0x07, 0x16 ); 								
			cs_lcd_i2c_write( lcd, 0x08, 0x0F );
			cs_lcd_i2c_write( lcd, 0x5d, 0xc9 );
			cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
			cs_lcd_i2c_write( lcd, 0x4c, 0x00 ); // Setting 19 pin as IIS SD0
		} else { // SPDIF output
			cs_lcd_i2c_write( lcd, 0xFF, 0x80 );
			cs_lcd_i2c_write( lcd, 0x08, 0x8F );
			cs_lcd_i2c_write( lcd, 0x5d, 0xc9 );
			cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
			cs_lcd_i2c_write( lcd, 0x4c, 0xbf ); // Setting 19 pin SPDIF
		}
	} else {  // Close Audio output
		cs_lcd_i2c_write( lcd, 0xFF, 0x60 );
		cs_lcd_i2c_write( lcd, 0x4c, 0xff );
		cs_lcd_i2c_write( lcd, 0x4d, 0xff );
	}
	/******************************AUDIO_CONFIG********************************/
	
	return 0;	
}

static int cs_lcd_probe(struct i2c_client *client, const struct i2c_device_id *id)
{
	struct device *dev = &client->dev;
    struct cs_lcd *lcd;
	int ret;
	u16 chipid;
	
	lcd = devm_kzalloc(dev, sizeof(*lcd), GFP_KERNEL);
    if (!lcd) {
		return -ENOMEM;
    }
	
	lcd->client = client;
	
	chipid = get_chip_id(lcd);
	dev_info(dev, "CS Chip ID is %#x.\n",chipid);
	if (chipid != 0x1604) {
		dev_err(dev, "This device is not CS LCD Chip(LT8618C), quit!\n");
		return -1;
	} else {
		dev_info(dev, "Finded CS LCD Chip(LT8619C)!!");
		hdmi_timing_read(lcd);
	}
	
	ret = cs_lcd_chip_init(lcd);
	if (ret) {
		dev_err(dev, "cs_lcd_chip_init failer.\n");
	}
	dev_info(dev, "cs_lcd probe successfully!");
	
	i2c_set_clientdata(client, lcd);

	return ret;
}

static int cs_lcd_remove(struct i2c_client *client)
{
	return 0;
}

static const struct i2c_device_id cs_lcd_i2c_ids[] = {
    { "cs_lcd", 0 },
    { }
};
MODULE_DEVICE_TABLE(i2c, cs_lcd_i2c_ids);

#ifdef CONFIG_OF
static const struct of_device_id cs_lcd_of_ids[] = {
    { .compatible = "chipsee,cs_lcd" },
    { }
};
MODULE_DEVICE_TABLE(of, cs_lcd_of_ids);
#endif

static struct i2c_driver cs_lcd_driver = {
    .driver = {
            .name = "cs_lcd",
            .of_match_table =of_match_ptr(cs_lcd_of_ids),
    },
    .id_table = cs_lcd_i2c_ids,
    .probe = cs_lcd_probe,
    .remove = cs_lcd_remove,
};
module_i2c_driver(cs_lcd_driver);

MODULE_AUTHOR("Xiaoqiang Liu <lxq@chipsee.com>");
MODULE_DESCRIPTION("Chipsee LCD Driver");
MODULE_LICENSE("GPL v2");
