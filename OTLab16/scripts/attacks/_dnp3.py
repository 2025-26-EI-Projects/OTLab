#!/usr/bin/env python3
"""Minimal DNP3-over-TCP frame builder for the Zeek Lab attack scenarios.
"""
import socket
import struct

# DNP3 CRC: poly 0x3D65, reflected (use 0xA6BC), init 0x0000, xor-out 0xFFFF,
_CRC_POLY = 0xA6BC


def dnp3_crc(data):
    crc = 0x0000
    for b in data:
        crc ^= b
        for _ in range(8):
            crc = ((crc >> 1) ^ _CRC_POLY) if (crc & 1) else (crc >> 1)
    crc = (~crc) & 0xFFFF
    return struct.pack("<H", crc)


def _data_blocks(user_data):
    """Split user data into <=16-octet blocks, each followed by its 2-byte CRC."""
    out = b""
    for i in range(0, len(user_data), 16):
        chunk = user_data[i:i + 16]
        out += chunk + dnp3_crc(chunk)
    return out


def build_link_frame(dst, src, user_data, ctrl=0xC4):
    
    length = 5 + len(user_data)
    if length > 255:
        raise ValueError("frame too long; transport segmentation is not implemented")
    header = bytes([0x05, 0x64, length, ctrl]) + struct.pack("<H", dst) + struct.pack("<H", src)
    header += dnp3_crc(header)
    return header + _data_blocks(user_data)


def transport_segment(app_fragment, fir=True, fin=True, seq=0):
    
    th = (0x80 if fin else 0) | (0x40 if fir else 0) | (seq & 0x3F)
    return bytes([th]) + app_fragment


def build_app_request(func_code, obj_headers=b"", seq=0, app_ctrl=None):
    
    if app_ctrl is None:
        app_ctrl = 0xC0 | (seq & 0x0F)
    return bytes([app_ctrl, func_code]) + obj_headers


def obj_header_all(group, variation=0):
    
    return bytes([group, variation, 0x06])


FC_READ = 0x01


def read_request(dst_link, src_link, group, variation=0, seq=0):
    
    app = build_app_request(FC_READ, obj_header_all(group, variation), seq=seq)
    return build_link_frame(dst_link, src_link, transport_segment(app))


def send_frame(host, port, frame, recv_timeout=2.0, sock=None):
    
    own = sock is None
    if own:
        sock = socket.create_connection((host, port), timeout=recv_timeout)
    try:
        sock.sendall(frame)
        sock.settimeout(recv_timeout)
        try:
            return sock.recv(4096)
        except socket.timeout:
            return b""
    finally:
        if own:
            sock.close()


class Dnp3Channel:
    """A TCP channel to a DNP3 endpoint that transparently (re)connects.

    Some outstations -- opendnp3 included -- drop the current TCP session when a
    new client connects or after an unexpected request. This hides that: each
    ``send_recv`` lazily opens a connection and, on a write failure, retries once
    on a fresh one. The lab scenarios only need the PDUs to reach the wire so
    Zeek parses them on the EWS; this keeps that happening even when the
    outstation keeps hanging up.
    """

    def __init__(self, host, port, connect_timeout=3.0, recv_timeout=0.3):
        self.host = host
        self.port = port
        self.connect_timeout = connect_timeout
        self.recv_timeout = recv_timeout
        self._sock = None

    def _ensure_connected(self):
        if self._sock is None:
            self._sock = socket.create_connection((self.host, self.port),
                                                  timeout=self.connect_timeout)

    def send_recv(self, frame):
        
        for attempt in (1, 2):
            self._ensure_connected()
            try:
                self._sock.sendall(frame)
            except OSError:
                self.close()
                if attempt == 2:
                    raise
                continue
            self._sock.settimeout(self.recv_timeout)
            try:
                return self._sock.recv(4096)
            except socket.timeout:
                return b""
            except OSError:
                self.close()
                return b""
        return b""

    def close(self):
        if self._sock is not None:
            try:
                self._sock.close()
            except OSError:
                pass
            self._sock = None

    def __enter__(self):
        return self

    def __exit__(self, *_exc):
        self.close()
