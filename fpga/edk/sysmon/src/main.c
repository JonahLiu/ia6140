
#include <stdio.h>

#include <xparameters.h>
#include <xgpio.h>
#include <xil_types.h>
#include <xil_printf.h>

#include "platform.h"

#define IO_DIR_MASK				(0xFFFFFFFF)

#define PHY_BITS				(8)
#define MDC_OFFSET(a)			(a*PHY_BITS+0)
#define MDIO_OFFSET(a)			(a*PHY_BITS+1)
#define LINK_OFFSET(a)			(a*PHY_BITS+2)
#define SPEED_OFFSET(a)			(a*PHY_BITS+3)
#define DUPLEX_OFFSET(a)		(a*PHY_BITS+5)
#define RESET_OFFSET(a)			(a*PHY_BITS+7)

#define	SPEED_10M				(0u)
#define SPEED_100M				(1u)
#define SPEED_1000M				(2u)

#define LED_OFFSET(a)			(24+a*2)
#define LED_OFF					(0u)
#define LED_BLINK_SLOW			(1u)
#define LED_BLINK_FAST			(2u)
#define LED_ON					(3u)

#define IO_DIR_INPUT			(1)
#define IO_DIR_OUTPUT			(0)

#define MDIO_SOF				(0x1u)
#define MDIO_SOF_SHIFT			(30)

#define MDIO_OP_READ			(0x2u)
#define MDIO_OP_WRITE			(0x1u)
#define MDIO_OP_SHIFT			(28)

#define MDIO_PADR_MASK			(0x1fu)
#define MDIO_PADR_SHIFT			(23)

#define MDIO_RADR_MASK			(0x1fu)
#define MDIO_RADR_SHIFT			(18)

#define MDIO_TA					(0x2u)
#define MDIO_TA_SHIFT			(16)

#define PHY0_PADDR				(0u)
#define PHY1_PADDR				(0u)
#define PHY2_PADDR				(0u)

#define PHY_REG_CTRL			(0)
#define PHY_REG_CTRL_RST		(1u<<15)

#define PHY_REG_STAT			(1)

#define PHY_REG_IDH				(2)
#define M88E1111_IDH			(0x0141u)

#define PHY_REG_IDL				(3)

#define PHY_REG_PSSR			(17)
#define PHY_REG_PSSR_LINK(a)	((a>>10)&0x1u)
#define PHY_REG_PSSR_SPEED(a)	((a>>14)&0x3u)
#define PHY_REG_PSSR_DUPLEX(a)	((a>>13)&0x1u)

#define PHY_REG_EPSC			(20)
#define PHY_REG_EPSC_RRTC		(1u<<7)
#define PHY_REG_EPSC_RTTC		(1u<<1)



typedef struct {
	u8 mdc_offset;
	u8 mdio_offset;
	u8 link_offset;
	u8 speed_offset;
	u8 duplex_offset;
	u8 reset_offset;
	u8 phy_addr;
} PHY_cfg;

typedef struct {
	u8 state;
} PHY;

void print(char *str);

static XGpio gpio;
static PHY_cfg phyCfg[3]={
		{MDC_OFFSET(0),MDIO_OFFSET(0),LINK_OFFSET(0),SPEED_OFFSET(0),DUPLEX_OFFSET(0),RESET_OFFSET(0),PHY0_PADDR},
		{MDC_OFFSET(1),MDIO_OFFSET(1),LINK_OFFSET(1),SPEED_OFFSET(1),DUPLEX_OFFSET(1),RESET_OFFSET(1),PHY1_PADDR},
		{MDC_OFFSET(2),MDIO_OFFSET(2),LINK_OFFSET(2),SPEED_OFFSET(2),DUPLEX_OFFSET(2),RESET_OFFSET(2),PHY2_PADDR},
};
static PHY phy[3]={{0},{0},{0}};

void delay(u32 d)
{
	while(d--);
}

void IO_SetDirection(u8 bit, u8 dir)
{
	u32 mask;
	mask = XGpio_GetDataDirection(&gpio, 1);

	if(dir==IO_DIR_OUTPUT)
		mask &= (~(1u<<bit));
	else if(dir==IO_DIR_INPUT)
		mask |= (1u<<bit);

	XGpio_SetDataDirection(&gpio, 1, mask);
}

void IO_Set(u8 bit)
{
	XGpio_DiscreteSet(&gpio, 1, (1u<<bit));
}

void IO_Clear(u8 bit)
{
	XGpio_DiscreteClear(&gpio, 1, (1u<<bit));
}

u8 IO_Get(u8 bit)
{
	u32 data=XGpio_DiscreteRead(&gpio, 1);
	return (data>>bit)&1u;
}

void MDIO_shift_out(PHY_cfg *cfg, u32 data, u8 n)
{
	u32 mask;

	IO_SetDirection(cfg->mdc_offset, IO_DIR_OUTPUT);
	IO_SetDirection(cfg->mdio_offset, IO_DIR_OUTPUT);

	while(n>0)
	{
		mask = 1u<<(n-1);

		IO_Clear(cfg->mdc_offset);

		if(data & mask)
			IO_Set(cfg->mdio_offset);
		else
			IO_Clear(cfg->mdio_offset);

		IO_Set(cfg->mdc_offset);

		--n;
	}
}

u32 MDIO_shift_in(PHY_cfg *cfg, u8 n)
{
	u32 mask;
	u32 data=0;

	IO_SetDirection(cfg->mdc_offset, IO_DIR_OUTPUT);
	IO_SetDirection(cfg->mdio_offset, IO_DIR_INPUT);
	IO_Clear(cfg->mdio_offset);

	while(n>0)
	{
		IO_Clear(cfg->mdc_offset);

		mask = 1u<<(n-1);
		if(IO_Get(cfg->mdio_offset))
			data|=mask;

		IO_Set(cfg->mdc_offset);

		--n;
	}
	return data;
}

void MDIO_write(PHY_cfg *cfg, u8 offset, u16 data)
{
	u32 tmp;
	tmp = 0xffffffff;
	MDIO_shift_out(cfg, tmp, 32);

	tmp = (MDIO_SOF<<MDIO_SOF_SHIFT) | (MDIO_OP_WRITE<<MDIO_OP_SHIFT) |
			((cfg->phy_addr&MDIO_PADR_MASK)<<MDIO_PADR_SHIFT) |
			((offset&MDIO_RADR_MASK)<<MDIO_RADR_SHIFT) | (MDIO_TA<<MDIO_TA_SHIFT) | data;
	MDIO_shift_out(cfg, tmp, 32);
}

s32 MDIO_read(PHY_cfg *cfg, u8 offset)
{
	u32 tmp;
	tmp = 0xffffffff;
	MDIO_shift_out(cfg, tmp, 32);

	tmp = (MDIO_SOF<<MDIO_SOF_SHIFT) | (MDIO_OP_READ<<MDIO_OP_SHIFT) |
				((cfg->phy_addr&MDIO_PADR_MASK)<<MDIO_PADR_SHIFT) |
				((offset&MDIO_RADR_MASK)<<MDIO_RADR_SHIFT) | (MDIO_TA<<MDIO_TA_SHIFT);
	tmp = tmp>>18;

	MDIO_shift_out(cfg, tmp, 14);
	tmp = MDIO_shift_in(cfg, 18);

	if(tmp&0x10000u)
		return -1;
	else
		return tmp&0xffffu;
}

void ResetPhy(PHY_cfg *cfg)
{
	IO_SetDirection(cfg->reset_offset, IO_DIR_OUTPUT);
	IO_Clear(cfg->reset_offset);
}

void EnablePhy(PHY_cfg *cfg)
{
	IO_SetDirection(cfg->reset_offset, IO_DIR_OUTPUT);
	IO_Set(cfg->reset_offset);
}

int InitPhy(PHY_cfg *cfg)
{
	u32 d;
	u32 ctrl;

	// Check PHY presence
	d=MDIO_read(cfg, PHY_REG_IDH);
	if(d!=M88E1111_IDH)
		return -1;

	// Reset PHY
	ctrl=d=MDIO_read(cfg, PHY_REG_CTRL);
	d|=PHY_REG_CTRL_RST;
	MDIO_write(cfg, PHY_REG_CTRL, d);

	// Enable RGMII clock delay
	d=MDIO_read(cfg, PHY_REG_EPSC);
	d|=PHY_REG_EPSC_RRTC|PHY_REG_EPSC_RTTC;
	MDIO_write(cfg, PHY_REG_EPSC, d);

	// Release PHY reset
	d=ctrl&(~PHY_REG_CTRL_RST);
	MDIO_write(cfg, PHY_REG_CTRL, d);

	return 0;
}

int main()
{
	u32 d;
	int i;

    init_platform();

    XGpio_Initialize(&gpio,0);
    XGpio_SetDataDirection(&gpio, 1, IO_DIR_MASK);

    for(i=0;i<3;i++)
    {
    	//Assert PHY reset
    	ResetPhy(&phyCfg[i]);
    }

    delay(100000);

    for(i=0;i<3;i++)
    {
    	// Release PHY reset
    	EnablePhy(&phyCfg[i]);
    }

    delay(100000);

    for(i=0;i<3;i++)
    {
    	InitPhy(&phyCfg[i]);
    }

    while(1)
    {
    	for(i=0;i<3;i++)
    	{
    		u8 link;
    		u8 speed;
    		u8 duplex;
    		d=MDIO_read(&phyCfg[i], PHY_REG_PSSR);
    		link=PHY_REG_PSSR_LINK(d);
    		speed=PHY_REG_PSSR_SPEED(d);
    		duplex=PHY_REG_PSSR_DUPLEX(d);
    		d=0;
    	}
    }
    return 0;
}
