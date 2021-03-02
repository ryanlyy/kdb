#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <linux/if_tun.h>
#include <fcntl.h>

int open_tun (const char *dev, char *actual, int size)
{
  struct ifreq ifr;
  int fd;
  char *device = "/dev/net/tun";
  if ((fd = open (device, O_RDWR)) < 0) 
    printf("Cannot open TUN/TAP dev %s", device);
  memset (&ifr, 0, sizeof (ifr));
  ifr.ifr_flags = IFF_NO_PI|IFF_MULTI_QUEUE;
  if (!strncmp (dev, "tun", 3)) {  
      ifr.ifr_flags |= IFF_TUN;
   }
  else if (!strncmp (dev, "tap", 3)) {
      ifr.ifr_flags |= IFF_TAP;
    }
  else {
    printf("I don't recognize device %s as a TUN or TAP device",dev);
    }
  if (strlen (dev) > 3)      /* unit number specified? */
    strncpy (ifr.ifr_name, dev, IFNAMSIZ);
  if (ioctl (fd, TUNSETIFF, (void *) &ifr) < 0) 
    printf( "Cannot ioctl TUNSETIFF %s", dev);
  //set_nonblock (fd);
  printf("TUN/TAP device %s opened", ifr.ifr_name);
  strncpy(actual, ifr.ifr_name, size);
  return fd;
}

int main()
{
	char realname[100];
	open_tun("tap123", realname, sizeof(realname));
	printf("realname is %s\n", realname);
	while ( 1 )
	{
		sleep(1);
	}
}

