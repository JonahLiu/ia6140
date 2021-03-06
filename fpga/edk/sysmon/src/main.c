
#include <stdio.h>

#include <xparameters.h>
#include <xgpio.h>
#include <xil_types.h>
#include <xil_printf.h>

#include "platform.h"

#define CIPHER_SIZE				(8)
#define DECIPHER_KEY			{0x55, 0x6F, 0x0F, 0x77, 0xE8, 0x62, 0xE0, 0xB6}

#define IO_DIR_MASK				(0x00000000)

#define FLASH_KEY_ADDR			(0x80000)

#define PHY_BITS				(8)
#define MDC_OFFSET(a)			(a*PHY_BITS+0)
#define MDIO_OFFSET(a)			(a*PHY_BITS+1)
#define LINK_OFFSET(a)			(a*PHY_BITS+2)
#define SPEED_OFFSET(a)			(a*PHY_BITS+3)
#define DUPLEX_OFFSET(a)		(a*PHY_BITS+5)
#define RESET_OFFSET(a)			(a*PHY_BITS+7)

#define CH_SEL_OFFSET			(24)
#define SPI_SCLK				(25)
#define SPI_MOSI				(26)
#define SPI_MISO				(27)
#define FLASH_CS				(28)
#define WDG_EN					(29)
#define OPTION_0				(30)
#define OPTION_1				(31)


#define UP_ALWAYS_EN		(OPTION_0)

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
#define PHY_REG_CTRL_ANEG_EN	(1u<<12)
#define PHY_REG_CTRL_PD			(1u<<11)
#define PHY_REG_CTRL_RENEG		(1u<<9)
#define PHY_REG_CTRL_DUPLEX		(1u<<8)
#define PHY_REG_CTRL_SPD_MASK 	((1u<<6)|(1u<<13))
#define PHY_REG_CTRL_SPD_1000	(1u<<6)
#define PHY_REG_CTRL_SPD_100	(1u<<13)
#define PHY_REG_CTRL_SPD_10		(0u)


#define PHY_REG_STAT			(1)

#define PHY_REG_IDH				(2)
#define M88E1111_IDH			(0x0141u)

#define PHY_REG_IDL				(3)

#define PHY_REG_ANAR			(4)
#define PHY_REG_ANAR_100F		(1u<<8)
#define PHY_REG_ANAR_100H		(1u<<7)
#define PHY_REG_ANAR_10F		(1u<<6)
#define PHY_REG_ANAR_10H		(1u<<5)

#define PHY_REG_GBCR			(9)
#define PHY_REG_GBCR_TEST_MASK	(0x7u<<13)
#define PHY_REG_GBCR_TEST_WAVE	(0x1u<<13)
#define PHY_REG_GBCR_1000F		(1u<<9)
#define PHY_REG_GBCR_1000H		(1u<<8)

#define PHY_REG_PSCR			(16)
#define PHY_REG_PSCR_TFD_MAX	(0x3u<<14)
#define PHY_REG_PSCR_RFD_MAX	(0x3u<<12)
#define PHY_REG_PSCR_EXT		(1u<<7)

#define PHY_REG_PSSR			(17)
#define PHY_REG_PSSR_LINK(a)	((a>>10)&0x1u)
#define PHY_REG_PSSR_SPEED(a)	((a>>14)&0x3u)
#define PHY_REG_PSSR_DUPLEX(a)	((a>>13)&0x1u)
#define PHY_REG_PSSR_LENGTH(a)	((a>>7)&0x7u)

#define PHY_REG_IER				(18)

#define PHY_REG_ISR				(19)
#define PHY_REG_ISR_SERR			(1u<<9)
#define PHY_REG_ISR_FCAR			(1u<<8)

#define PHY_REG_EPSC			(20)
#define PHY_REG_EPSC_RRTC		(1u<<7)
#define PHY_REG_EPSC_RTTC		(1u<<1)

#define PHY_REG_RECR			(21)

#define PHY_REG_LEDC			(24)
#define PHY_REG_LEDC_DISABLE	(1u<<15)

#define LINK_HOLDOFF			(1000)
#define ERROR_THRESHOLD			(10)


typedef struct {
	u8 mdc_offset;
	u8 mdio_offset;
	u8 link_offset;
	u8 speed_offset;
	u8 duplex_offset;
	u8 reset_offset;
	u8 phy_addr;
	u8 offset;
} PHY_cfg;

typedef struct {
	u8 link:1,speed:2,duplex:3,changed:1;
	u8 length;
	u32 rx_err;
	u32 link_time;
} PHY;

void print(char *str);

static XGpio gpio;
static PHY_cfg phyCfg[3]={
		{MDC_OFFSET(0),MDIO_OFFSET(0),LINK_OFFSET(0),SPEED_OFFSET(0),DUPLEX_OFFSET(0),RESET_OFFSET(0),PHY0_PADDR},
		{MDC_OFFSET(1),MDIO_OFFSET(1),LINK_OFFSET(1),SPEED_OFFSET(1),DUPLEX_OFFSET(1),RESET_OFFSET(1),PHY1_PADDR},
		{MDC_OFFSET(2),MDIO_OFFSET(2),LINK_OFFSET(2),SPEED_OFFSET(2),DUPLEX_OFFSET(2),RESET_OFFSET(2),PHY2_PADDR},
};
static PHY phy[3];

static u8 decipher_key[8] = DECIPHER_KEY;

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

void IO_SetBit(u8 bit, u8 value)
{
	if(value)
		XGpio_DiscreteSet(&gpio, 1, (1u<<bit));
	else
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

	//IO_SetDirection(cfg->mdc_offset, IO_DIR_OUTPUT);
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

	//IO_SetDirection(cfg->mdc_offset, IO_DIR_OUTPUT);
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

void SPI_shift_out(u32 data, u8 n)
{
	u32 mask;

	while(n>0)
	{
		mask = 1u<<(n-1);

		IO_Clear(SPI_SCLK);

		if(data & mask)
			IO_Set(SPI_MOSI);
		else
			IO_Clear(SPI_MOSI);

		IO_Set(SPI_SCLK);

		--n;
	}

	IO_Clear(SPI_SCLK);
}

u32 SPI_shift_in(u8 n)
{
	u32 mask;
	u32 data=0;

	while(n>0)
	{
		IO_Clear(SPI_SCLK);

		mask = 1u<<(n-1);
		if(IO_Get(SPI_MISO))
			data|=mask;

		IO_Set(SPI_SCLK);

		--n;
	}
	IO_Clear(SPI_SCLK);
	return data;
}

size_t FLASH_read(u32 addr, char *buf, size_t size)
{
	size_t n;
	u32 data;
	IO_Set(FLASH_CS);

	data = (0x3u<<24)|(addr&0xffffff);
	SPI_shift_out(data, 32);

	n=0;
	while(n<size)
	{
		buf[n++] = SPI_shift_in(8);
	}

	IO_Clear(FLASH_CS);
	return n;
}

size_t KEY_write(char *buf, size_t size)
{
	size_t n;
	u32 data;
	IO_Set(WDG_EN);
	n=0;
	while(n<size)
	{
		data = buf[n++];
		SPI_shift_out(data,8);
	}
	IO_Clear(WDG_EN);
	return n;
}

void ResetPhy(PHY_cfg *cfg)
{
	//IO_SetDirection(cfg->reset_offset, IO_DIR_OUTPUT);
	IO_Clear(cfg->reset_offset);
}

void EnablePhy(PHY_cfg *cfg)
{
	//IO_SetDirection(cfg->reset_offset, IO_DIR_OUTPUT);
	IO_Set(cfg->reset_offset);
}

int InitPhy(PHY_cfg *cfg)
{
	u32 d;

	// Check PHY presence
	d=MDIO_read(cfg, PHY_REG_IDH);
	if(d!=M88E1111_IDH)
		return -1;

	// Enable RGMII clock delay
	d=MDIO_read(cfg, PHY_REG_EPSC);
	d|=PHY_REG_EPSC_RRTC|PHY_REG_EPSC_RTTC;
	MDIO_write(cfg, PHY_REG_EPSC, d);

	//d=MDIO_read(cfg, PHY_REG_PSCR);
	//d|=PHY_REG_PSCR_TFD_MAX | PHY_REG_PSCR_RFD_MAX;
	//d|=PHY_REG_PSCR_EXT;
	//MDIO_write(cfg, PHY_REG_PSCR, d);

	d=0xFFFF;
	MDIO_write(cfg, PHY_REG_IER, d);

	d=PHY_REG_LEDC_DISABLE;
	MDIO_write(cfg, PHY_REG_LEDC, d);

	// Soft Reset
	d=MDIO_read(cfg, PHY_REG_CTRL);
	d|=PHY_REG_CTRL_RST;
	MDIO_write(cfg, PHY_REG_CTRL, d);

	return 0;
}

void SelectChannel(int ch)
{
	//IO_SetDirection(CH_SEL_OFFSET, IO_DIR_OUTPUT);
	if(ch)
		IO_Set(CH_SEL_OFFSET);
	else
		IO_Clear(CH_SEL_OFFSET);
}

void UpdateChannelStatus(void)
{
	int i;
	for(i=0;i<3;i++)
	{
		u16 d;
		d=MDIO_read(&phyCfg[i], PHY_REG_PSSR);
		// WORKAROUND: Add a delay to avoid the short unstable period after link setup
		if(PHY_REG_PSSR_LINK(d))
		{
			if(phy[i].link_time<LINK_HOLDOFF)
			{
				phy[i].link_time++;
			}
			else
			{
				if(phy[i].link!=1 || phy[i].speed!=PHY_REG_PSSR_SPEED(d) ||
						phy[i].duplex!=PHY_REG_PSSR_DUPLEX(d))
					phy[i].changed=1;

				phy[i].link = 1;
				phy[i].speed = PHY_REG_PSSR_SPEED(d);
				phy[i].duplex = PHY_REG_PSSR_DUPLEX(d);
				phy[i].length = PHY_REG_PSSR_LENGTH(d);

				d=MDIO_read(&phyCfg[i], PHY_REG_RECR);
				phy[i].rx_err = d;

				if(phy[i].rx_err>ERROR_THRESHOLD)
				{
					phy[i].link=0;
					phy[i].link_time=0;
					phy[i].changed=1;
				}

			}
		}
		else
		{
			if(phy[i].link)
				phy[i].changed=1;

			phy[i].link=0;
			phy[i].link_time=0;
			//phy[i].speed=0;
			//phy[i].duplex=0;
			//phy[i].length=0;
			//phy[i].rx_err=0;
		}

		if(phy[i].changed)
		{
			IO_SetBit(phyCfg[i].link_offset, phy[i].link);
			IO_SetBit(phyCfg[i].speed_offset, phy[i].speed&0x1);
			IO_SetBit(phyCfg[i].speed_offset+1, (phy[i].speed&0x2)>>1);
			IO_SetBit(phyCfg[i].duplex_offset, phy[i].duplex);
		}
	}
}
/*
void TestPHYSpeed(void)
{
	u32 d;
	d = MDIO_read(&phyCfg[0], PHY_REG_CTRL);
	d &= (~(PHY_REG_CTRL_SPD_MASK|PHY_REG_CTRL_ANEG_EN|PHY_REG_CTRL_DUPLEX));

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_SPD_1000|PHY_REG_CTRL_DUPLEX|PHY_REG_CTRL_RST);

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_SPD_1000|PHY_REG_CTRL_RST);

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_SPD_100|PHY_REG_CTRL_DUPLEX|PHY_REG_CTRL_RST);

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_SPD_100|PHY_REG_CTRL_RST);

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_SPD_10|PHY_REG_CTRL_DUPLEX|PHY_REG_CTRL_RST);

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_SPD_10|PHY_REG_CTRL_RST);

	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d|PHY_REG_CTRL_ANEG_EN|PHY_REG_CTRL_RST);
}

void TestFlashRead(void)
{
	char buf[16];
	FLASH_read(0,buf, sizeof(buf));
	FLASH_read(16, buf, sizeof(buf));
}
*/

void Decipher(char *buf, size_t size)
{
	int i;
	for(i=0;i<size;i++)
	{
		buf[i] = buf[i]^decipher_key[i];
	}
}

void GetKey(char *buf, size_t size)
{
	FLASH_read(FLASH_KEY_ADDR, buf, size);
	Decipher(buf, size);
}

void SetupLink(int master, u8 up_always_on)
{
	u32 d;
	if(phy[master].link)
	{
		if(!phy[0].link)
		{
			d = MDIO_read(&phyCfg[0], PHY_REG_CTRL);
			d &= ~PHY_REG_CTRL_PD;
			MDIO_write(&phyCfg[0], PHY_REG_CTRL, d);
		}
	}
	else
	{
		if(!up_always_on)
		{
			d = MDIO_read(&phyCfg[0], PHY_REG_CTRL);
			d |= PHY_REG_CTRL_PD;
			MDIO_write(&phyCfg[0], PHY_REG_CTRL, d);
		}
		return ;
	}

	if(phy[master].speed != phy[0].speed ||
			phy[master].duplex != phy[0].duplex)
	{
		d = MDIO_read(&phyCfg[0], PHY_REG_ANAR);
		d &= (~(PHY_REG_ANAR_100F|PHY_REG_ANAR_100H|PHY_REG_ANAR_10F|PHY_REG_ANAR_10H));
		if(phy[master].speed==SPEED_100M)
		{
			if(phy[master].duplex)
				d |= PHY_REG_ANAR_100F;
			else
				d |= PHY_REG_ANAR_100H;
		}
		else if(phy[master].speed==SPEED_10M)
		{
			if(phy[master].duplex)
				d |= PHY_REG_ANAR_10F;
			else
				d |= PHY_REG_ANAR_10H;
		}
		MDIO_write(&phyCfg[0], PHY_REG_ANAR, d);

		d = MDIO_read(&phyCfg[0], PHY_REG_GBCR);
		d &= (~(PHY_REG_GBCR_1000F|PHY_REG_GBCR_1000H));
		if(phy[master].speed==SPEED_1000M)
		{
			if(phy[master].duplex)
				d |= PHY_REG_GBCR_1000F;
			else
				d |= PHY_REG_GBCR_1000H;
		}
		MDIO_write(&phyCfg[0], PHY_REG_GBCR, d);

		d = MDIO_read(&phyCfg[0], PHY_REG_CTRL);
		d |= PHY_REG_CTRL_RENEG;
		MDIO_write(&phyCfg[0], PHY_REG_CTRL, d);
	}
}


static char key[CIPHER_SIZE+1];
int main()
{
	unsigned int i;
	u8 ch;
	u8 up_always_on;

    init_platform();

    XGpio_Initialize(&gpio,0);
    XGpio_SetDataDirection(&gpio, 1, IO_DIR_MASK);

    GetKey(key, CIPHER_SIZE);
    KEY_write(key, CIPHER_SIZE);

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

    up_always_on = IO_Get(UP_ALWAYS_EN);
    if(!up_always_on)
    {
    	u32 d = MDIO_read(&phyCfg[0], PHY_REG_CTRL);
    	d |= PHY_REG_CTRL_PD;
    	MDIO_write(&phyCfg[0], PHY_REG_CTRL, d);
    }

    ch=0;
    SelectChannel(0);

    i=0;
    while(1)
    {
    	//if((i++)%1000)
    	//	KEY_write(key, CIPHER_SIZE+1); // This will reset watchdog timer and re-launch

    	u8 switch_port = 0;

    	UpdateChannelStatus();

    	// Auto port switching with port 1 having higher priority
    	if((ch==0 && phy[1].link==0 && phy[2].link==1)||(ch==1 && phy[1].link==1))
    	{
    		switch_port=1;
    		ch=ch?0:1;
    		SelectChannel(ch);
    	}

    	// Match ports speed and duplexing
    	if(switch_port || phy[0].changed || phy[1].changed || phy[2].changed)
    	{
    		SetupLink(1+ch, up_always_on);
    		phy[0].changed = phy[1].changed = phy[2].changed = 0;
    	}
    }
    return 0;
}
