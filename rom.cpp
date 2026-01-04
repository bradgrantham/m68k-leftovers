#include <cstdint>

int main()
{
    uint8_t* high = (uint8_t*) (1 < 22);
    uint8_t* higher = (uint8_t*) (1 < 23);
    for(;;) {
	for(uint32_t i = 0; i < 500000; i++)
	{
	    *high = 0xff;
	}
	for(uint32_t i = 0; i < 500000; i++)
	{
	    *high = 0xff;
	}
    }
}
