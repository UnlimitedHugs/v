module net

const max_unix_path = 110

const addr_offset_fix = 0

struct C.addrinfo {
mut:
	ai_family    int
	ai_socktype  int
	ai_flags     int
	ai_protocol  int
	ai_addrlen   int
	ai_addr      voidptr
	ai_canonname voidptr
	ai_next      voidptr
}

struct C.sockaddr_in {
	sin_family u16
	sin_port   u16
	sin_addr   u32
}

struct C.sockaddr_in6 {
	sin6_family u16
	sin6_port   u16
	sin6_addr   [4]u32
}

struct C.sockaddr_un {
	sun_family u16
	sun_path   [max_unix_path]char
}

[_pack: '2']
struct Ip6 {
	port      u16
	flow_info u32
	addr      [16]byte
	scope_id  u32
	sin6_pad  [2]byte
}

[_pack: '4']
struct Ip {
	port    u16
	addr    [4]byte
	sin_pad [10]byte
}

struct Unix {
	path [max_unix_path]byte
}

[_pack: '8']
struct Addr {
pub:
	f    u16
	addr AddrData
}
