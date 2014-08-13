#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <libgen.h>
#include <unistd.h>
#include <linux/limits.h>
#include <linux/input.h>
#include <signal.h>

#define PORT_MIN 0
#define PORT_MAX 65535
#define MC_LOOPBACK 1
#define MC_TTL 1

#define DEBUG
int timeperjump=3;

const char* RUN_BASE="/tmp/evdev-emitter/";

void error(char *msg) {
  fputs(msg, stderr);
  fputc('\n', stderr);
  exit(EXIT_FAILURE);
}

void main(int argc, char **argv) {
  int device_fd, sock_fd, run_fd;
  struct sockaddr_in sock_addr;
  char run_file[PATH_MAX];
  struct stat sb;

  if (argc != 3) {
    fprintf(stderr, "Usage: %s <ip-addr> <ip-port>\n", basename(argv[0]));
    exit(EXIT_FAILURE);
  }


  memset(&sock_addr, 0, sizeof(sock_addr));
  sock_addr.sin_family = AF_INET;

  if (inet_pton(AF_INET, argv[1], &sock_addr.sin_addr) <= 0)
    error("invalid address");

  unsigned int sock_port = (unsigned int) strtoul(argv[2], NULL, 10);
  if (sock_port < PORT_MIN || sock_port > PORT_MAX)
    error("invalid port");

  sock_addr.sin_port = htons(sock_port);

  sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sock_fd < 0) {
    perror("opening the socket");
    exit(EXIT_FAILURE);
  }

  u_char multicast_loop = MC_LOOPBACK;
  u_char multicast_ttl = MC_TTL;
  setsockopt(sock_fd, IPPROTO_IP, IP_MULTICAST_LOOP, &multicast_loop, sizeof(multicast_loop));
  setsockopt(sock_fd, IPPROTO_IP, IP_MULTICAST_TTL, &multicast_ttl, sizeof(multicast_ttl));



  #ifdef DEBUG
    fprintf(stderr, "sending events from spaceNav to %s:%u\n", argv[1], sock_port);
  #endif

  /* initialize the input buffer */

  struct input_event ev;
  struct input_event *event_data = &ev;

  memset(event_data, 0, sizeof(ev));

  /* initialize the output buffer */
  char *device_name = "spacenavigator";
  size_t sock_buffer_size = strlen(device_name) + sizeof(ev);
  char sock_buffer[sock_buffer_size];

  memset(sock_buffer, 0, sock_buffer_size);

  strncpy(
    sock_buffer + sizeof(ev),
    device_name,
    sock_buffer_size - sizeof(ev)
  );

  /* begin relaying from the device to the socket */
struct timeval tval;  // removed comma

event_data->code=257;

  while(1) {

gettimeofday (&tval, NULL);
event_data->time=tval;
event_data->value=1;



    memcpy(sock_buffer, event_data, sizeof(ev));
    
    int num_sent = sendto(
      sock_fd,
      sock_buffer,
      sock_buffer_size,
      0,
      (struct sockaddr *) &sock_addr,
      sizeof(sock_addr)
    );

    if (num_sent < 0) {
      perror("sending to socket");
    }

    #ifdef DEBUG
      fprintf(
        stderr,
        "sent %d bytes from %s. type: %d code: %d value: %d\n",
        num_sent, device_name, event_data->type, event_data->code, event_data->value
     );
    #endif


gettimeofday (&tval, NULL);
event_data->time=tval;
event_data->value=0;

    memcpy(sock_buffer, event_data, sizeof(ev));
    
    num_sent = sendto(
      sock_fd,
      sock_buffer,
      sock_buffer_size,
      0,
      (struct sockaddr *) &sock_addr,
      sizeof(sock_addr)
    );

    if (num_sent < 0) {
      perror("sending to socket");
    }

    #ifdef DEBUG
      fprintf(
        stderr,
        "sent %d bytes from %s. type: %d code: %d value: %d\n",
        num_sent, device_name, event_data->type, event_data->code, event_data->value
     );
    #endif

sleep(timeperjump);
  }
}
