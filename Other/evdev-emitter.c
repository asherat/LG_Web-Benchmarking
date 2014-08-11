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

  if (argc != 4) {
    fprintf(stderr, "Usage: %s <event-device-file> <ip-addr> <ip-port>\n", basename(argv[0]));
    exit(EXIT_FAILURE);
  }

  // did some joker open a file with a ' in the name?
  if (strchr(argv[1], '\'') != NULL)
    error("\' character not allowed in device filename");
  // running over the buffer?
  if (strlen(argv[1]) >= NAME_MAX)
    error("device filename too long");

  memset(&sock_addr, 0, sizeof(sock_addr));
  sock_addr.sin_family = AF_INET;

  if (inet_pton(AF_INET, argv[2], &sock_addr.sin_addr) <= 0)
    error("invalid address");

  unsigned int sock_port = (unsigned int) strtoul(argv[3], NULL, 10);
  if (sock_port < PORT_MIN || sock_port > PORT_MAX)
    error("invalid port");

  sock_addr.sin_port = htons(sock_port);

  if ((device_fd = open(argv[1], O_RDONLY)) < 0) {
    perror("opening the file you specified");
    exit(EXIT_FAILURE);
  }

  sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sock_fd < 0) {
    perror("opening the socket");
    exit(EXIT_FAILURE);
  }

  u_char multicast_loop = MC_LOOPBACK;
  u_char multicast_ttl = MC_TTL;
  setsockopt(sock_fd, IPPROTO_IP, IP_MULTICAST_LOOP, &multicast_loop, sizeof(multicast_loop));
  setsockopt(sock_fd, IPPROTO_IP, IP_MULTICAST_TTL, &multicast_ttl, sizeof(multicast_ttl));

  // check the run lock, lock if needed
  char *device_name = basename(argv[1]);
  strncpy(run_file, RUN_BASE, strlen(RUN_BASE));
  strncat(run_file, device_name, strlen(device_name));
  if (stat(run_file, &sb) >= 0)
    error("device already running");

  mkdir(RUN_BASE, S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
  run_fd = open(run_file, O_RDONLY | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
  if (run_fd < 0)
    error("couldn't create the run lock");
  close(run_fd);

  void cleanup() {
    unlink(run_file);
    exit(EXIT_FAILURE);
  }

  // clear the lock upon untimely death
  signal(SIGINT, cleanup);
  signal(SIGTERM, cleanup);
  signal(SIGHUP, cleanup);
  signal(SIGQUIT, cleanup);
  signal(SIGSEGV, cleanup);

  #ifdef DEBUG
    fprintf(stderr, "sending events from %s to %s:%u\n", device_name, argv[2], sock_port);
  #endif

  /* initialize the input buffer */

  struct input_event ev;
  struct input_event *event_data = &ev;

  memset(event_data, 0, sizeof(ev));

  /* initialize the output buffer */

  size_t sock_buffer_size = strlen(device_name) + sizeof(ev);
  char sock_buffer[sock_buffer_size];

  memset(sock_buffer, 0, sock_buffer_size);

  strncpy(
    sock_buffer + sizeof(ev),
    device_name,
    sock_buffer_size - sizeof(ev)
  );

  /* begin relaying from the device to the socket */

  while(1) {
    int num_read = read(device_fd, event_data, sizeof(ev));

    if (sizeof(ev) != num_read) {
      fputs("read failed\n", stderr);
      cleanup();
    }

    if (event_data->type == EV_SYN || event_data->type == EV_MSC)
      continue; // ignore EV_MSC and EV_SYN events

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
  }
}
